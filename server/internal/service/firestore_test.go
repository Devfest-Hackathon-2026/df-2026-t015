package service

import (
	"context"
	"os"
	"sync"
	"testing"
	"time"

	"cloud.google.com/go/firestore"
	"google.golang.org/api/option"
)

func TestFirestoreTransactions(t *testing.T) {
	if os.Getenv("FIRESTORE_EMULATOR_HOST") == "" {
		t.Skip("FIRESTORE_EMULATOR_HOST is not configured")
	}
	ctx, cancel := context.WithTimeout(t.Context(), 30*time.Second)
	defer cancel()
	client, err := firestore.NewClient(ctx, "demo-iterinerary", option.WithoutAuthentication())
	if err != nil {
		t.Fatal(err)
	}
	defer client.Close()
	store := FirestoreStore{Client: client}
	trip := Itinerary{Title: "test", Date: time.Now().Format("2006-01-02"), Items: []Item{}, Legs: []Leg{}, Dropped: []Dropped{}, ExpiresAt: time.Now().Add(time.Hour).Format(time.RFC3339)}
	if err := store.Create(ctx, "owner", &trip); err != nil {
		t.Fatal(err)
	}
	defer client.Collection("itineraries").Doc(trip.ID).Delete(context.Background())
	if _, err := store.Get(ctx, "other", trip.ID); err == nil || APIError(err).Status != 404 {
		t.Fatalf("ownership: %v", err)
	}
	var group sync.WaitGroup
	results := make(chan error, 2)
	for range 2 {
		group.Go(func() { next := trip; results <- store.Update(ctx, "owner", trip.ID, 1, &next) })
	}
	group.Wait()
	close(results)
	success, conflict := 0, 0
	for err := range results {
		if err == nil {
			success++
		} else if APIError(err).Status == 409 {
			conflict++
		} else {
			t.Fatal(err)
		}
	}
	if success != 1 || conflict != 1 {
		t.Fatalf("success=%d conflict=%d", success, conflict)
	}
	current, err := store.Get(ctx, "owner", trip.ID)
	if err != nil {
		t.Fatal(err)
	}
	proposal := Replan{ItineraryID: trip.ID, BasedOnVersion: current.Version, NeedsChange: true, ExpiresAt: time.Now().Add(time.Minute).Format(time.RFC3339), Options: []Option{{OptionID: "op", Candidate: current}}, Explanations: map[string]Explanation{"op": {Status: "pending"}}}
	if err := store.SaveReplan(ctx, "owner", &proposal); err != nil {
		t.Fatal(err)
	}
	defer client.Collection("replans").Doc(proposal.ReplanID).Delete(context.Background())
	claimed, ok, err := store.ClaimExplanation(ctx, "owner", trip.ID, proposal.ReplanID, "op")
	if err != nil || !ok {
		t.Fatalf("claim: %v %v", ok, err)
	}
	if _, ok, err := store.ClaimExplanation(ctx, "owner", trip.ID, proposal.ReplanID, "op"); err != nil || ok {
		t.Fatalf("duplicate claim: %v %v", ok, err)
	}
	if err := store.FinishExplanation(ctx, "owner", trip.ID, proposal.ReplanID, "op", claimed.Lease, Explanation{Status: "failed"}); err != nil {
		t.Fatal(err)
	}
	if result, err := store.Accept(ctx, "owner", trip.ID, proposal.ReplanID, "op", current.Version); err != nil || result.Version != current.Version+1 {
		t.Fatalf("accept after explanation failure: %+v %v", result, err)
	}
	if err := store.Delete(ctx, "other", trip.ID, current.Version+1); err == nil || APIError(err).Status != 404 {
		t.Fatalf("delete by another user: %v", err)
	}
	if err := store.Delete(ctx, "owner", trip.ID, current.Version); err == nil || APIError(err).Status != 409 {
		t.Fatalf("delete with old version: %v", err)
	}
	if err := store.Delete(ctx, "owner", trip.ID, current.Version+1); err != nil {
		t.Fatal(err)
	}
	if _, err := client.Collection("replans").Doc(proposal.ReplanID).Get(ctx); err == nil {
		t.Fatal("replan remained after deleting the itinerary")
	}
}
