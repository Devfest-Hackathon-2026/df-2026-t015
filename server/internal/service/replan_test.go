package service

import (
	"context"
	"io"
	"net/http"
	"strconv"
	"strings"
	"testing"
	"time"
)

func TestDelayPreservesPastAndCurrent(t *testing.T) {
	delay := 40
	trip := Itinerary{Date: "2026-11-14", Items: []Item{
		{ItemID: "done", PlaceID: "a", StartAt: "2026-11-14T09:00:00+09:00", EndAt: "2026-11-14T10:00:00+09:00", StayMin: 60},
		{ItemID: "current", PlaceID: "b", StartAt: "2026-11-14T10:30:00+09:00", EndAt: "2026-11-14T11:30:00+09:00", StayMin: 60},
		{ItemID: "next", PlaceID: "c", StartAt: "2026-11-14T12:00:00+09:00", EndAt: "2026-11-14T13:00:00+09:00", StayMin: 60},
	}}
	prefix, depart, err := DelayedPrefix(trip, ReplanInput{CurrentItemID: "current", DelayMin: &delay})
	if err != nil || len(prefix) != 2 || prefix[0].EndAt != trip.Items[0].EndAt || prefix[1].StartAt != trip.Items[1].StartAt || depart.Format("15:04") != "12:10" {
		t.Fatalf("%+v %v %v", prefix, depart, err)
	}
	if trip.Items[1].EndAt != "2026-11-14T11:30:00+09:00" {
		t.Fatal("input mutated")
	}
	if prefix[0].Status != "done" || prefix[1].Status != "current" {
		t.Fatal("statuses not retained")
	}
}

func TestReplanInput(t *testing.T) {
	delay := 1
	for _, input := range []ReplanInput{{CurrentItemID: "x"}, {CurrentItemID: "x", DelayMin: &delay, Now: time.Now().Format(time.RFC3339)}, {CurrentItemID: "x", Now: "bad"}} {
		if err := ValidateReplan(input); err == nil {
			t.Fatalf("accepted %+v", input)
		}
	}
	delay = 601
	if ValidateReplan(ReplanInput{CurrentItemID: "x", DelayMin: &delay}) == nil {
		t.Fatal("large delay accepted")
	}
}

func TestChangesIncludeReplacementAndRetime(t *testing.T) {
	old := Itinerary{Items: []Item{{ItemID: "a", PlaceID: "p1", EndAt: "old"}, {ItemID: "b", PlaceID: "p2"}}}
	next := Itinerary{Items: []Item{{ItemID: "a", PlaceID: "p1", EndAt: "new"}, {ItemID: "c", PlaceID: "p3"}}}
	changes := Changes(old, next)
	counts := map[string]int{}
	for _, change := range changes {
		counts[change.Type]++
	}
	if counts["replace"] != 1 || counts["retime"] != 1 {
		t.Fatalf("%+v", changes)
	}
}

func TestSuggestionsRejectOccupiedWindow(t *testing.T) {
	app := App{}
	trip := Itinerary{Date: "2026-11-14", Start: Start{PlaceID: "start", DepartAt: "2026-11-14T09:00:00+09:00"}, EndBy: "17:00", Items: []Item{{ItemID: "a", EndAt: "2026-11-14T12:00:00+09:00"}}}
	from, _ := time.Parse(time.RFC3339, "2026-11-14T11:00:00+09:00")
	to := from.Add(time.Hour)
	if _, err := app.Suggest(t.Context(), trip, from, to, "a"); err == nil || APIError(err).Status != 400 {
		t.Fatalf("occupied time accepted: %v", err)
	}
}

func TestReplanRejectsMissingAIPlaceIDs(t *testing.T) {
	trip := Itinerary{ID: "trip", Version: 1, Title: "旅", Date: "2026-11-14", Start: Start{PlaceID: "start", DepartAt: "2026-11-14T09:00:00+09:00"}, EndBy: "17:00", Items: []Item{{ItemID: "a", PlaceID: "p1", Priority: "must", StartAt: "2026-11-14T09:00:00+09:00", EndAt: "2026-11-14T10:00:00+09:00", StayMin: 60}, {ItemID: "b", PlaceID: "p2", Priority: "want", StartAt: "2026-11-14T10:10:00+09:00", EndAt: "2026-11-14T11:10:00+09:00", StayMin: 60}}, Legs: []Leg{{ToItemID: "b", DurationMin: 10}}}
	for _, malformed := range []string{`{}`, `null`, `{"placeIds":null}`} {
		client := &http.Client{Transport: roundTripFunc(func(r *http.Request) (*http.Response, error) {
			body := `{"id":"p1","displayName":{"text":"p1"},"location":{"latitude":35,"longitude":139}}`
			if strings.Contains(r.URL.Path, "searchText") {
				body = `{"places":[]}`
			}
			return &http.Response{StatusCode: 200, Header: make(http.Header), Body: io.NopCloser(strings.NewReader(body))}, nil
		})}
		aiJSON := `{"options":[` + malformed + `]}`
		ai := &Gemini{HTTP: testHTTP(`{"candidates":[{"content":{"parts":[{"text":` + strconv.Quote(aiJSON) + `}]},"finishReason":"STOP"}]}`)}
		app := App{Maps: &Maps{HTTP: client}, AI: ai}
		delay := 20
		if _, err := app.Replan(context.Background(), trip, ReplanInput{CurrentItemID: "a", DelayMin: &delay}); err == nil || APIError(err).Status != 502 {
			t.Errorf("accepted %s: %v", malformed, err)
		}
	}
}

func TestReplanRetimesAbsorbedDelay(t *testing.T) {
	trip := Itinerary{ID: "trip", Version: 1, Date: "2026-11-14", EndBy: "17:00", Items: []Item{{ItemID: "a", PlaceID: "p1", StartAt: "2026-11-14T09:00:00+09:00", EndAt: "2026-11-14T10:00:00+09:00", StayMin: 60}, {ItemID: "b", PlaceID: "p2", StartAt: "2026-11-14T11:00:00+09:00", EndAt: "2026-11-14T12:00:00+09:00", StayMin: 60}}, Legs: []Leg{{ToItemID: "b", DurationMin: 10}}}
	app := App{}
	delay := 5
	for _, items := range [][]Item{trip.Items, trip.Items[:1]} {
		trip.Items = items
		result, err := app.Replan(context.Background(), trip, ReplanInput{CurrentItemID: "a", DelayMin: &delay})
		if err != nil || !result.NeedsChange || len(result.Options) != 1 {
			t.Errorf("lost delay: %+v %v", result, err)
			continue
		}
		next := result.Options[0].Candidate
		if next.Items[0].EndAt != "2026-11-14T10:05:00+09:00" || len(next.Items) != len(items) {
			t.Fatalf("%+v", next.Items)
		}
		if len(items) > 1 && next.Items[1].StartAt != items[1].StartAt {
			t.Fatal("absorbed delay changed future visit")
		}
	}
}

func TestSuggestRejectsMissingAIField(t *testing.T) {
	client := &http.Client{Transport: roundTripFunc(func(r *http.Request) (*http.Response, error) {
		body := `{"id":"start","displayName":{"text":"start"},"location":{"latitude":35,"longitude":139}}`
		if strings.Contains(r.URL.Path, "searchText") {
			body = `{"places":[{"id":"p3","displayName":{"text":"p3"},"location":{"latitude":35,"longitude":139}}]}`
		}
		return &http.Response{StatusCode: 200, Header: make(http.Header), Body: io.NopCloser(strings.NewReader(body))}, nil
	})}
	app := App{Maps: &Maps{HTTP: client}, AI: &Gemini{HTTP: testHTTP(`{"candidates":[{"content":{"parts":[{"text":"{}"}]},"finishReason":"STOP"}]}`)}}
	trip := Itinerary{Date: "2026-11-14", Start: Start{PlaceID: "start", DepartAt: "2026-11-14T09:00:00+09:00"}, EndBy: "17:00"}
	from, _ := time.Parse(time.RFC3339, "2026-11-14T10:00:00+09:00")
	if _, err := app.Suggest(t.Context(), trip, from, from.Add(time.Hour), ""); err == nil || APIError(err).Status != 502 {
		t.Fatalf("missing AI suggestions field accepted: %v", err)
	}
}
