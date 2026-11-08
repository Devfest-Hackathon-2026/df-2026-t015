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

func TestListCursorAndEntry(t *testing.T) {
	cursor := encodeCursor(listCursor{Date: "2026-11-14", ID: "trip"})
	if c, err := decodeCursor(cursor); err != nil || c.ID != "trip" || c.Date != "2026-11-14" {
		t.Fatalf("%+v %v", c, err)
	}
	for _, bad := range []string{"%%%", "e30", encodeCursor(listCursor{Date: "2026-11-14", ID: "a/b"})} {
		if _, err := decodeCursor(bad); err == nil || APIError(err).Status != 400 {
			t.Fatalf("accepted %q", bad)
		}
	}
	record := itineraryRecord{Date: "2026-11-14", UpdatedAt: time.Now(), ExpiresAt: time.Now(), Data: Itinerary{Title: "旅",
		Start: Start{Name: "駅", DepartAt: "2026-11-14T09:00:00+09:00"}, End: End{Name: "駅", ArriveAt: "2026-11-14T16:05:00+09:00"},
		Items: []Item{{Name: "a"}, {Name: "b"}, {Name: "c"}, {Name: "d"}}}}
	entry := entryFor("trip", record)
	if entry.PlaceCount != 4 || len(entry.PlaceNames) != 3 || entry.End.ArriveAt != "2026-11-14T16:05:00+09:00" || entry.ExpiresAt == "" {
		t.Fatalf("%+v", entry)
	}
}
