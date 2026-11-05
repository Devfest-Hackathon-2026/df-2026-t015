package service

import (
	"testing"
	"time"
)

func TestStoredOwnershipAndExpiry(t *testing.T) {
	now := time.Now()
	record := itineraryRecord{OwnerUID: "owner", ExpiresAt: now.Add(time.Hour), Data: Itinerary{Version: 3}}
	if err := record.check("other", now); APIError(err).Status != 404 {
		t.Fatalf("other owner: %v", err)
	}
	if err := record.check("owner", now); err != nil {
		t.Fatal(err)
	}
	if err := record.check("owner", now.Add(2*time.Hour)); APIError(err).Status != 404 {
		t.Fatalf("expired itinerary: %v", err)
	}
	proposal := replanRecord{OwnerUID: "owner", ItineraryID: "trip", ExpiresAt: now.Add(time.Minute)}
	if err := proposal.check("other", "trip", now); APIError(err).Status != 404 {
		t.Fatal(err)
	}
	if err := proposal.check("owner", "wrong", now); APIError(err).Status != 404 {
		t.Fatal(err)
	}
	if err := proposal.check("owner", "trip", now.Add(time.Hour)); APIError(err).Status != 410 {
		t.Fatal(err)
	}
}

func TestAcceptValidation(t *testing.T) {
	now := time.Now()
	trip := itineraryRecord{OwnerUID: "owner", ExpiresAt: now.Add(time.Hour), Data: Itinerary{Version: 3}}
	proposal := replanRecord{OwnerUID: "owner", ItineraryID: "trip", ExpiresAt: now.Add(time.Minute), Data: Replan{BasedOnVersion: 3, Options: []Option{{OptionID: "op1", Candidate: Itinerary{Title: "new"}}}}}
	if _, err := accepted(trip, proposal, "owner", "trip", "op1", 2, now); APIError(err).Status != 409 {
		t.Fatal(err)
	}
	if _, err := accepted(trip, proposal, "owner", "trip", "unknown", 3, now); APIError(err).Status != 400 {
		t.Fatal(err)
	}
	proposal.Data.Explanations = map[string]Explanation{"op1": {Status: "failed"}}
	value, err := accepted(trip, proposal, "owner", "trip", "op1", 3, now)
	if err != nil || value.Title != "new" || value.Version != 4 {
		t.Fatalf("%+v %v", value, err)
	}
}
