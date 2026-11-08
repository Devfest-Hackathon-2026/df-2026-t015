package service

import (
	"context"
	"crypto/rand"
	"crypto/sha256"
	"encoding/base64"
	"encoding/json"
	"fmt"
	"time"

	"cloud.google.com/go/firestore"
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

// Create は旅程を保存する。期限内の旅程が MaxItineraries 件ある場合は ITINERARY_LIMIT を返す。
func (s *FirestoreStore) Create(ctx context.Context, uid string, value *Itinerary) error {
	ref := s.Client.Collection("itineraries").NewDoc()
	value.ID = ref.ID
	value.Version = 1
	record, err := recordFor(uid, *value)
	if err != nil {
		return err
	}
	err = s.Client.RunTransaction(ctx, func(ctx context.Context, tx *firestore.Transaction) error {
		docs, err := tx.Documents(s.Client.Collection("itineraries").Where("ownerUid", "==", uid)).GetAll()
		if err != nil {
			return err
		}
		active := 0
		now := time.Now()
		for _, doc := range docs {
			var existing itineraryRecord
			if err := doc.DataTo(&existing); err != nil {
				return err
			}
			if existing.check(uid, now) == nil {
				active++
			}
		}
		if active >= MaxItineraries {
			return ItineraryLimit()
		}
		return tx.Create(ref, record)
	})
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

// Count は期限内の本人の旅程の件数を返す。
func (s *FirestoreStore) Count(ctx context.Context, uid string) (int, error) {
	docs, err := s.Client.Collection("itineraries").Where("ownerUid", "==", uid).Select("expiresAt").Documents(ctx).GetAll()
	if err != nil {
		return 0, storeError(err)
	}
	count := 0
	now := time.Now()
	for _, doc := range docs {
		if expires, err := doc.DataAt("expiresAt"); err == nil {
			if t, ok := expires.(time.Time); ok && now.Before(t) {
				count++
			}
		}
	}
	return count, nil
}

// listCursor は一覧の続きの位置（旅行日とドキュメントID）。
type listCursor struct {
	Date string `json:"d"`
	ID   string `json:"i"`
}

func encodeCursor(c listCursor) string {
	data, _ := json.Marshal(c)
	return base64.RawURLEncoding.EncodeToString(data)
}

func decodeCursor(value string) (listCursor, error) {
	var c listCursor
	data, err := base64.RawURLEncoding.DecodeString(value)
	if err != nil || json.Unmarshal(data, &c) != nil || !ValidID(c.ID) || c.Date == "" {
		return listCursor{}, Invalid("cursor が不正です")
	}
	return c, nil
}

// entryFor は一覧に出す1件を旅程から作る。
func entryFor(id string, record itineraryRecord) ItineraryEntry {
	value := record.Data
	names := []string{}
	for _, item := range value.Items {
		if len(names) < 3 {
			names = append(names, item.Name)
		}
	}
	return ItineraryEntry{
		ID: id, Title: value.Title, Date: record.Date,
		Start:      EntryStart{Name: value.Start.Name, DepartAt: value.Start.DepartAt},
		End:        EntryEnd{Name: value.End.Name, ArriveAt: value.End.ArriveAt},
		PlaceCount: len(value.Items), PlaceNames: names,
		UpdatedAt: record.UpdatedAt.Format(time.RFC3339), ExpiresAt: record.ExpiresAt.In(JST).Format(time.RFC3339),
	}
}

// List は本人の旅程を旅行日の新しい順に limit 件返す。ownerUid + date の複合インデックスを使う。
func (s *FirestoreStore) List(ctx context.Context, uid string, limit int, cursor string) (ItineraryPage, error) {
	query := s.Client.Collection("itineraries").Where("ownerUid", "==", uid).OrderBy("date", firestore.Desc).OrderBy(firestore.DocumentID, firestore.Desc)
	if cursor != "" {
		c, err := decodeCursor(cursor)
		if err != nil {
			return ItineraryPage{}, err
		}
		query = query.StartAfter(c.Date, c.ID)
	}
	docs, err := query.Limit(limit + 1).Documents(ctx).GetAll()
	if err != nil {
		return ItineraryPage{}, storeError(err)
	}
	page := ItineraryPage{Itineraries: []ItineraryEntry{}}
	if len(docs) > limit {
		docs = docs[:limit]
		last := docs[len(docs)-1]
		var record itineraryRecord
		if err := last.DataTo(&record); err != nil {
			return ItineraryPage{}, Upstream()
		}
		next := encodeCursor(listCursor{Date: record.Date, ID: last.Ref.ID})
		page.NextCursor = &next
	}
	now := time.Now()
	for _, doc := range docs {
		var record itineraryRecord
		if err := doc.DataTo(&record); err != nil {
			return ItineraryPage{}, Upstream()
		}
		// TTL の実削除は遅れるため、期限切れはここで除く。
		if record.check(uid, now) != nil {
			continue
		}
		page.Itineraries = append(page.Itineraries, entryFor(doc.Ref.ID, record))
	}
	return page, nil
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

// Delete は旅程と、その旅程の組み直し案を1つのトランザクションで削除する。
// 本人の旅程でなければ 404、version が違えば 409。
func (s *FirestoreStore) Delete(ctx context.Context, uid, id string, version int) error {
	ref := s.Client.Collection("itineraries").Doc(id)
	err := s.Client.RunTransaction(ctx, func(ctx context.Context, tx *firestore.Transaction) error {
		doc, err := tx.Get(ref)
		if err != nil {
			return err
		}
		var record itineraryRecord
		if err := doc.DataTo(&record); err != nil {
			return err
		}
		if err := record.check(uid, time.Now()); err != nil {
			return err
		}
		if record.Data.Version != version {
			return Conflict()
		}
		replans, err := tx.Documents(s.Client.Collection("replans").Where("itineraryId", "==", id)).GetAll()
		if err != nil {
			return err
		}
		for _, replan := range replans {
			if err := tx.Delete(replan.Ref); err != nil {
				return err
			}
		}
		return tx.Delete(ref)
	})
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
