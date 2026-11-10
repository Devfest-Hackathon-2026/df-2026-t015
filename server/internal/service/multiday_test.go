package service

import (
	"encoding/json"
	"testing"
	"time"
)

func overnightInput(t *testing.T) PlanInput {
	t.Helper()
	var input PlanInput
	err := json.Unmarshal([]byte(`{"title":"夜の旅行","date":"2026-11-20","start":{"placeId":"start","departAt":"23:00"},"end":{"placeId":"end","date":"2026-11-21","arriveBy":"01:00"},"places":[{"placeId":"a","priority":"must","stayMin":30}]}`), &input)
	if err != nil {
		t.Fatal(err)
	}
	return input
}

func TestOvernightPlan(t *testing.T) {
	input := overnightInput(t)
	if err := ValidatePlan(input); err != nil {
		t.Fatalf("overnight plan rejected: %v", err)
	}
	var legacy PlanInput
	if err := json.Unmarshal([]byte(`{"title":"日帰り","date":"2026-11-20","start":{"placeId":"start","departAt":"23:00"},"end":{"placeId":"end","arriveBy":"01:00"},"places":[{"placeId":"a","priority":"must","stayMin":30}]}`), &legacy); err != nil {
		t.Fatal(err)
	}
	if err := ValidatePlan(legacy); err == nil {
		t.Fatal("missing end date must keep same-day validation")
	}
}

func TestDelayAcrossMidnight(t *testing.T) {
	trip := Itinerary{Date: "2026-11-20", Items: []Item{{ItemID: "night", EndAt: "2026-11-20T23:50:00+09:00", StayMin: 30}}}
	prefix, depart, err := DelayedPrefix(trip, ReplanInput{CurrentItemID: "night", Now: "2026-11-21T00:20:00+09:00"})
	if err != nil {
		t.Fatal(err)
	}
	if depart.Format(time.RFC3339) != "2026-11-21T00:20:00+09:00" || prefix[0].StayMin != 60 {
		t.Fatalf("incorrect delay: %v %+v", depart, prefix)
	}
}

func TestNextDayOpening(t *testing.T) {
	arrival, _ := time.Parse(time.RFC3339, "2026-11-20T23:00:00+09:00")
	limit := arrival.Add(12 * time.Hour)
	hours := &Hours{Periods: []Period{{Open: HourPoint{Day: 6, Hour: 9}, Close: &HourPoint{Day: 6, Hour: 18}}}}
	start, _, ok := OpenAtUntil(hours, arrival, 60, limit)
	if !ok || start.Format(time.RFC3339) != "2026-11-21T09:00:00+09:00" {
		t.Fatalf("next-day opening: %v %v", start, ok)
	}
	if _, _, ok := OpenAtUntil(hours, arrival, 60, arrival.Add(10*time.Hour)); ok {
		t.Fatal("visit finishing after deadline accepted")
	}
}

func TestOvernightCopy(t *testing.T) {
	input := overnightInput(t)
	app := &App{Maps: &Maps{HTTP: placesHTTP(), Transit: &Transit{Key: "test", HTTP: transitHTTP(10)}}}
	trip, err := app.schedule(t.Context(), input, map[string]Place{}, nil, nil, false)
	if err != nil {
		t.Fatal(err)
	}
	if trip.End.Date != "2026-11-21" || trip.ExpiresAt != "2026-12-21T00:00:00+09:00" {
		t.Fatalf("wrong end/expiry: %+v", trip)
	}
	copy, err := app.Copy(t.Context(), trip, "2026-12-01", "")
	if err != nil {
		t.Fatal(err)
	}
	if copy.End.Date != "2026-12-02" {
		t.Fatalf("copy lost day offset: %+v", copy.End)
	}
}

func TestEditSecondDay(t *testing.T) {
	app := &App{Maps: &Maps{HTTP: placesHTTP(), Transit: &Transit{Key: "test", HTTP: transitHTTP(10)}}, AI: geminiReturning(`{"placeIds":["b"]}`)}
	trip := Itinerary{Title: "二日間", Date: "2026-11-20", Start: Start{PlaceID: ref("a"), DepartAt: "2026-11-20T23:00:00+09:00"}, End: End{Date: "2026-11-21", PlaceID: ref("a"), ArriveBy: "18:00"}, Items: []Item{{ItemID: "fixed", PlaceID: "a", Name: "A", Status: "current", Priority: "must", StayMin: 60, StartAt: "2026-11-21T09:00:00+09:00", EndAt: "2026-11-21T10:00:00+09:00"}}}
	next, err := app.Edit(t.Context(), trip, EditInput{Places: []Visit{{PlaceID: "a", Priority: "must", StayMin: 60}, {PlaceID: "b", Priority: "must", StayMin: 60}}})
	if err != nil {
		t.Fatal(err)
	}
	if next.Date != trip.Date || next.Start.DepartAt != trip.Start.DepartAt || len(next.Items) != 2 || next.Items[1].StartAt < "2026-11-21T10:00:00+09:00" {
		t.Fatalf("partial edit returned to first day: %+v", next)
	}
}

func TestSuggestionsSecondDay(t *testing.T) {
	app := &App{Maps: &Maps{HTTP: placesHTTP(), Transit: &Transit{Key: "test", HTTP: transitHTTP(10)}}, AI: geminiReturning(`{"suggestions":[],"ideas":[]}`)}
	trip := Itinerary{Date: "2026-11-20", Start: Start{PlaceID: ref("a"), DepartAt: "2026-11-20T23:00:00+09:00"}, End: End{Date: "2026-11-21", PlaceID: ref("a"), ArriveBy: "18:00"}, Items: []Item{{ItemID: "a", PlaceID: "a", EndAt: "2026-11-21T10:00:00+09:00"}}}
	from, _ := time.Parse(time.RFC3339, "2026-11-21T11:00:00+09:00")
	if _, err := app.Suggest(t.Context(), trip, from, from.Add(time.Hour), "a"); err != nil {
		t.Fatal(err)
	}
}

func TestDelayUsesNewService(t *testing.T) {
	app := &App{Maps: &Maps{HTTP: placesHTTP(), Transit: &Transit{Key: "test", HTTP: transitHTTP(25)}}}
	trip := Itinerary{Date: "2026-11-20", End: End{Date: "2026-11-21", PlaceID: ref("end"), ArriveBy: "18:00"}, Items: []Item{{ItemID: "a", PlaceID: "a", EndAt: "2026-11-21T10:00:00+09:00", StayMin: 60}, {ItemID: "b", PlaceID: "b", StartAt: "2026-11-21T11:00:00+09:00", EndAt: "2026-11-21T12:00:00+09:00"}}, Legs: []Leg{{FromItemID: "a", ToItemID: "b", DurationMin: 10}, {FromItemID: "b", ToItemID: "end", ArriveAt: "2026-11-21T12:10:00+09:00"}}}
	delay := 5
	result, err := app.Replan(t.Context(), trip, ReplanInput{CurrentItemID: "a", DelayMin: &delay})
	if err != nil {
		t.Fatal(err)
	}
	candidate := result.Options[0].Candidate
	if candidate.Legs[0].ArriveAt != "2026-11-21T10:30:00+09:00" || candidate.Legs[0].DurationMin != 25 || candidate.Items[1].StartAt != trip.Items[1].StartAt {
		t.Fatalf("old transit duration reused: %+v", candidate)
	}
}

func TestSuggestionsSkipUnreachablePlace(t *testing.T) {
	places := testHTTP(`{"places":[{"id":"cafe","displayName":{"text":"カフェ"},"location":{"latitude":35.001,"longitude":139}}]}`)
	app := &App{Maps: &Maps{HTTP: places, Transit: &Transit{Key: "test", HTTP: transitClient(`{"ResultSet":{"apiVersion":"1","Course":[]}}`, 200)}}}
	from, _ := At("2026-11-21", "10:00")
	candidates, err := app.gapCandidates(t.Context(), Itinerary{}, Waypoint{Location: Point{Lat: 35, Lng: 139}, HasLocation: true}, Waypoint{Location: Point{Lat: 34, Lng: 139}, HasLocation: true}, Point{Lat: 35, Lng: 139}, from, from.Add(time.Hour))
	if err != nil || len(candidates) != 0 {
		t.Fatalf("unreachable candidate blocked all suggestions: %+v %v", candidates, err)
	}
}

func TestEditDateKeepsTripLength(t *testing.T) {
	app := &App{Maps: &Maps{HTTP: placesHTTP(), Transit: &Transit{Key: "test", HTTP: transitHTTP(10)}}}
	for _, endDay := range []string{"", "2026-11-21"} {
		trip := Itinerary{Title: "旅", Date: "2026-11-20", Start: Start{PlaceID: ref("start"), DepartAt: "2026-11-20T09:00:00+09:00"}, End: End{PlaceID: ref("end"), Date: endDay, ArriveBy: "18:00"}, Items: []Item{{ItemID: "a", PlaceID: "a", Priority: "must", StayMin: 30}}}
		date := "2026-12-01"
		next, err := app.Edit(t.Context(), trip, EditInput{Date: &date, Places: []Visit{{PlaceID: "a", Priority: "must", StayMin: 30}}})
		if err != nil {
			t.Fatal(err)
		}
		expected := "2026-12-01"
		if endDay != "" {
			expected = "2026-12-02"
		}
		if next.Date != date || next.End.Date != expected || next.Items[0].Status != "upcoming" {
			t.Fatalf("wrong shifted dates: %+v", next)
		}
	}
}

func TestAddSecondDay(t *testing.T) {
	app := &App{Maps: &Maps{HTTP: placesHTTP(), Transit: &Transit{Key: "test", HTTP: transitHTTP(10)}}}
	trip := Itinerary{Title: "旅", Date: "2026-11-20", Start: Start{PlaceID: ref("start"), DepartAt: "2026-11-20T23:00:00+09:00"}, End: End{PlaceID: ref("end"), Date: "2026-11-21", ArriveBy: "18:00"}, Items: []Item{{ItemID: "a", PlaceID: "a", Priority: "must", StayMin: 30, StartAt: "2026-11-21T09:00:00+09:00", EndAt: "2026-11-21T09:30:00+09:00"}}}
	next, err := app.Add(t.Context(), trip, AddInput{PlaceID: "b", Priority: "want", StayMin: 30, InsertAfterItemID: "a"})
	if err != nil {
		t.Fatal(err)
	}
	if next.Date != trip.Date || next.Start.DepartAt != trip.Start.DepartAt || len(next.Items) != 2 || next.Items[1].StartAt != "2026-11-21T09:40:00+09:00" {
		t.Fatalf("added item date rolled back: %+v", next)
	}
}

func TestReplanCanDropUnreachableNextPlace(t *testing.T) {
	app := &App{Maps: &Maps{HTTP: placesHTTP(), Transit: &Transit{Key: "test", HTTP: transitClient(`{"ResultSet":{"apiVersion":"1","Course":[]}}`, 200)}}}
	trip := Itinerary{Title: "旅", Date: "2026-11-20", Start: Start{PlaceID: ref("a"), DepartAt: "2026-11-20T23:00:00+09:00"}, End: End{PlaceID: ref("a"), Date: "2026-11-21", ArriveBy: "18:00"}, Items: []Item{{ItemID: "a", PlaceID: "a", EndAt: "2026-11-21T10:00:00+09:00", StayMin: 60}, {ItemID: "b", PlaceID: "b", Priority: "want", StayMin: 30, StartAt: "2026-11-21T10:10:00+09:00", EndAt: "2026-11-21T10:40:00+09:00"}}}
	delay := 20
	result, err := app.Replan(t.Context(), trip, ReplanInput{CurrentItemID: "a", DelayMin: &delay})
	if err != nil {
		t.Fatal(err)
	}
	if len(result.Options) != 1 || len(result.Options[0].Candidate.Items) != 1 || result.Options[0].Candidate.Date != trip.Date {
		t.Fatalf("unreachable next place prevented alternative: %+v", result)
	}
}
