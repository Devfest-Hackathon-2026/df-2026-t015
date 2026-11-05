package service

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"fmt"
	"sort"
	"time"

	"cloud.google.com/go/firestore"
	"google.golang.org/api/iterator"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

type FirestoreStore struct{ Client *firestore.Client }

type itineraryRecord struct {
	OwnerUID  string    `firestore:"ownerUid"`
	Date      string    `firestore:"date"`
	UpdatedAt time.Time `firestore:"updatedAt"`
	ExpiresAt time.Time `firestore:"expiresAt"`
	Data      Itinerary `firestore:"data"`
}

func (r itineraryRecord) check(uid string, now time.Time) error {
	if r.OwnerUID != uid || !now.Before(r.ExpiresAt) {
		return NotFound()
	}
	return nil
}

type replanRecord struct {
	OwnerUID    string    `firestore:"ownerUid"`
	ItineraryID string    `firestore:"itineraryId"`
	ExpiresAt   time.Time `firestore:"expiresAt"`
	Data        Replan    `firestore:"data"`
}

func (r replanRecord) check(uid, id string, now time.Time) error {
	if r.OwnerUID != uid || r.ItineraryID != id {
		return NotFound()
	}
	if !now.Before(r.ExpiresAt) {
		return Expired()
	}
	return nil
}

func storeError(err error) error {
	if err == nil {
		return nil
	}
	if _, ok := err.(*Error); ok {
		return err
	}
	switch status.Code(err) {
	case codes.NotFound:
		return NotFound()
	case codes.Aborted, codes.FailedPrecondition, codes.AlreadyExists:
		return Conflict()
	case codes.ResourceExhausted:
		return Fail(429, "RATE_LIMITED", "呼び出し上限に達しました")
	default:
		return Upstream()
	}
}

func recordFor(uid string, value Itinerary) (itineraryRecord, error) {
	expires, err := time.Parse(time.RFC3339, value.ExpiresAt)
	if err != nil {
		return itineraryRecord{}, Upstream()
	}
	return itineraryRecord{OwnerUID: uid, Date: value.Date, UpdatedAt: time.Now(), ExpiresAt: expires, Data: value}, nil
}

func (s *FirestoreStore) Create(ctx context.Context, uid string, value *Itinerary) error {
	ref := s.Client.Collection("itineraries").NewDoc()
	value.ID = ref.ID
	value.Version = 1
	record, err := recordFor(uid, *value)
	if err != nil {
		return err
	}
	_, err = ref.Create(ctx, record)
	return storeError(err)
}

func (s *FirestoreStore) Get(ctx context.Context, uid, id string) (Itinerary, error) {
	if !ValidID(id) {
		return Itinerary{}, NotFound()
	}
	snapshot, err := s.Client.Collection("itineraries").Doc(id).Get(ctx)
	if err != nil {
		return Itinerary{}, storeError(err)
	}
	var record itineraryRecord
	if err := snapshot.DataTo(&record); err != nil {
		return Itinerary{}, Upstream()
	}
	if err := record.check(uid, time.Now()); err != nil {
		return Itinerary{}, err
	}
	return record.Data, nil
}

func (s *FirestoreStore) List(ctx context.Context, uid string) ([]ItineraryEntry, error) {
	iter := s.Client.Collection("itineraries").Where("ownerUid", "==", uid).Documents(ctx)
	defer iter.Stop()
	entries := []ItineraryEntry{}
	for {
		doc, err := iter.Next()
		if err == iterator.Done {
			break
		}
		if err != nil {
			return nil, storeError(err)
		}
		var record itineraryRecord
		if err := doc.DataTo(&record); err != nil {
			return nil, Upstream()
		}
		if record.check(uid, time.Now()) != nil {
			continue
		}
		entries = append(entries, ItineraryEntry{ID: doc.Ref.ID, Title: record.Data.Title, Date: record.Date, UpdatedAt: record.UpdatedAt.Format(time.RFC3339)})
	}
	sort.Slice(entries, func(i, j int) bool {
		if entries[i].Date == entries[j].Date {
			return entries[i].UpdatedAt > entries[j].UpdatedAt
		}
		return entries[i].Date > entries[j].Date
	})
	return entries, nil
}

func (s *FirestoreStore) Update(ctx context.Context, uid, id string, version int, value *Itinerary) error {
	ref := s.Client.Collection("itineraries").Doc(id)
	candidate := *value
	candidate.ID = id
	candidate.Version = version + 1
	replacement, err := recordFor(uid, candidate)
	if err != nil {
		return err
	}
	err = s.Client.RunTransaction(ctx, func(ctx context.Context, tx *firestore.Transaction) error {
		doc, err := tx.Get(ref)
		if err != nil {
			return err
		}
		var old itineraryRecord
		if err := doc.DataTo(&old); err != nil {
			return err
		}
		if err := old.check(uid, time.Now()); err != nil {
			return err
		}
		if old.Data.Version != version {
			return Conflict()
		}
		return tx.Set(ref, replacement)
	})
	if err == nil {
		*value = candidate
	}
	return storeError(err)
}

func (s *FirestoreStore) SaveReplan(ctx context.Context, uid string, value *Replan) error {
	expires, err := time.Parse(time.RFC3339, value.ExpiresAt)
	if err != nil {
		return Upstream()
	}
	ref := s.Client.Collection("replans").NewDoc()
	value.ReplanID = ref.ID
	err = s.Client.RunTransaction(ctx, func(ctx context.Context, tx *firestore.Transaction) error {
		doc, err := tx.Get(s.Client.Collection("itineraries").Doc(value.ItineraryID))
		if err != nil {
			return err
		}
		var trip itineraryRecord
		if err := doc.DataTo(&trip); err != nil {
			return err
		}
		if err := trip.check(uid, time.Now()); err != nil {
			return err
		}
		if trip.Data.Version != value.BasedOnVersion {
			return Conflict()
		}
		return tx.Create(ref, replanRecord{OwnerUID: uid, ItineraryID: value.ItineraryID, ExpiresAt: expires, Data: *value})
	})
	return storeError(err)
}

func (s *FirestoreStore) GetReplan(ctx context.Context, uid, id, rid string) (Replan, error) {
	if _, err := s.Get(ctx, uid, id); err != nil {
		return Replan{}, err
	}
	doc, err := s.Client.Collection("replans").Doc(rid).Get(ctx)
	if err != nil {
		return Replan{}, storeError(err)
	}
	var record replanRecord
	if err := doc.DataTo(&record); err != nil {
		return Replan{}, Upstream()
	}
	if err := record.check(uid, id, time.Now()); err != nil {
		return Replan{}, err
	}
	return record.Data, nil
}

func accepted(trip itineraryRecord, proposal replanRecord, uid, id, option string, version int, now time.Time) (Itinerary, error) {
	if err := trip.check(uid, now); err != nil {
		return Itinerary{}, err
	}
	if err := proposal.check(uid, id, now); err != nil {
		return Itinerary{}, err
	}
	if trip.Data.Version != version || proposal.Data.BasedOnVersion != version {
		return Itinerary{}, Conflict()
	}
	for _, candidate := range proposal.Data.Options {
		if candidate.OptionID != option {
			continue
		}
		value := candidate.Candidate
		value.ID = id
		value.Version = version + 1
		return value, nil
	}
	return Itinerary{}, Invalid("optionId が不正です")
}

func (s *FirestoreStore) Accept(ctx context.Context, uid, id, rid, option string, version int) (Itinerary, error) {
	tripRef := s.Client.Collection("itineraries").Doc(id)
	var value Itinerary
	err := s.Client.RunTransaction(ctx, func(ctx context.Context, tx *firestore.Transaction) error {
		doc, err := tx.Get(tripRef)
		if err != nil {
			return err
		}
		var trip itineraryRecord
		if err := doc.DataTo(&trip); err != nil {
			return err
		}
		doc, err = tx.Get(s.Client.Collection("replans").Doc(rid))
		if err != nil {
			return err
		}
		var proposal replanRecord
		if err := doc.DataTo(&proposal); err != nil {
			return err
		}
		value, err = accepted(trip, proposal, uid, id, option, version, time.Now())
		if err != nil {
			return err
		}
		record, err := recordFor(uid, value)
		if err != nil {
			return err
		}
		return tx.Set(tripRef, record)
	})
	return value, storeError(err)
}

func (s *FirestoreStore) ClaimExplanation(ctx context.Context, uid, id, rid, option string) (Explanation, bool, error) {
	ref := s.Client.Collection("replans").Doc(rid)
	lease := rand.Text()
	var explanation Explanation
	claimed := false
	err := s.Client.RunTransaction(ctx, func(ctx context.Context, tx *firestore.Transaction) error {
		claimed = false
		doc, err := tx.Get(s.Client.Collection("itineraries").Doc(id))
		if err != nil {
			return err
		}
		var trip itineraryRecord
		if err := doc.DataTo(&trip); err != nil {
			return err
		}
		if err := trip.check(uid, time.Now()); err != nil {
			return err
		}
		doc, err = tx.Get(ref)
		if err != nil {
			return err
		}
		var record replanRecord
		if err := doc.DataTo(&record); err != nil {
			return err
		}
		if err := record.check(uid, id, time.Now()); err != nil {
			return err
		}
		found := false
		for _, value := range record.Data.Options {
			if value.OptionID == option {
				found = true
			}
		}
		if !found {
			return Invalid("optionId が不正です")
		}
		if record.Data.Explanations == nil {
			record.Data.Explanations = map[string]Explanation{}
		}
		explanation = record.Data.Explanations[option]
		if explanation.Status == "ready" || explanation.Status == "failed" || time.Now().Before(explanation.LeaseUntil) {
			return nil
		}
		explanation = Explanation{Status: "pending", Lease: lease, LeaseUntil: time.Now().Add(30 * time.Second)}
		record.Data.Explanations[option] = explanation
		claimed = true
		return tx.Set(ref, record)
	})
	return explanation, claimed, storeError(err)
}

func (s *FirestoreStore) FinishExplanation(ctx context.Context, uid, id, rid, option, lease string, explanation Explanation) error {
	ref := s.Client.Collection("replans").Doc(rid)
	err := s.Client.RunTransaction(ctx, func(ctx context.Context, tx *firestore.Transaction) error {
		doc, err := tx.Get(ref)
		if err != nil {
			return err
		}
		var record replanRecord
		if err := doc.DataTo(&record); err != nil {
			return err
		}
		if err := record.check(uid, id, time.Now()); err != nil {
			return err
		}
		if record.Data.Explanations[option].Lease != lease {
			return nil
		}
		record.Data.Explanations[option] = explanation
		return tx.Set(ref, record)
	})
	return storeError(err)
}

func (s *FirestoreStore) Allow(ctx context.Context, uid string) error {
	ref := s.Client.Collection("rateLimits").Doc(fmt.Sprintf("%x", sha256.Sum256([]byte(uid))))
	err := s.Client.RunTransaction(ctx, func(ctx context.Context, tx *firestore.Transaction) error {
		now := time.Now()
		var record struct {
			Window    int64     `firestore:"window"`
			Count     int       `firestore:"count"`
			ExpiresAt time.Time `firestore:"expiresAt"`
		}
		doc, err := tx.Get(ref)
		if err != nil && status.Code(err) != codes.NotFound {
			return err
		}
		if err == nil {
			if err := doc.DataTo(&record); err != nil {
				return err
			}
		}
		window := now.Unix() / 60
		if record.Window != window {
			record.Window = window
			record.Count = 0
		}
		if record.Count >= 120 {
			return Fail(429, "RATE_LIMITED", "1分あたりの呼び出し上限に達しました")
		}
		record.Count++
		record.ExpiresAt = now.Add(2 * time.Minute)
		return tx.Set(ref, record)
	})
	return storeError(err)
}
