package service

import (
	"context"
	"testing"
	"time"
)

func TestVisitOrderRejectsInventedAndDuplicateIDs(t *testing.T) {
	visits := []Visit{{PlaceID: "a", Priority: "must", StayMin: 60}, {PlaceID: "b", Priority: "want", StayMin: 30}}
	for _, ids := range [][]string{{"a", "fake"}, {"a", "a"}, {"a"}} {
		if _, err := OrderedVisits(visits, ids); err == nil {
			t.Fatalf("accepted %v", ids)
		}
	}
	if ordered, err := OrderedVisits(visits, []string{"b", "a"}); err != nil || ordered[0].PlaceID != "b" {
		t.Fatalf("%v %v", ordered, err)
	}
}

func TestOpeningHours(t *testing.T) {
	arrival := time.Date(2026, 11, 5, 12, 30, 0, 0, JST)
	hours := &Hours{Periods: []Period{
		{Open: HourPoint{Day: 4, Hour: 9}, Close: &HourPoint{Day: 4, Hour: 12}},
		{Open: HourPoint{Day: 4, Hour: 14}, Close: &HourPoint{Day: 4, Hour: 18}},
	}}
	start, _, ok := OpenAt(hours, arrival, 60)
	if !ok || start.Hour() != 14 {
		t.Fatalf("lunch break: %v %v", start, ok)
	}
	if _, _, ok := OpenAt(hours, arrival, 300); ok {
		t.Fatal("visit beyond closing accepted")
	}
	if _, _, ok := OpenAt(&Hours{}, arrival, 30); ok {
		t.Fatal("closed day accepted")
	}
	if _, window, ok := OpenAt(nil, arrival, 30); !ok || window != nil {
		t.Fatal("unknown hours must remain unknown")
	}
	overnight := &Hours{Periods: []Period{{Open: HourPoint{Day: 3, Hour: 22}, Close: &HourPoint{Day: 4, Hour: 2}}}}
	if _, _, ok := OpenAt(overnight, arrival.Add(-12*time.Hour), 30); !ok {
		t.Fatal("overnight opening not recognized")
	}
}

func TestValidatePlan(t *testing.T) {
	input := PlanInput{Title: "旅", Date: "2026-11-14", Start: Start{PlaceID: "start", DepartAt: "09:00"}, EndBy: "17:00", Places: []Visit{{PlaceID: "a", Priority: "must", StayMin: 60}}}
	if err := ValidatePlan(input); err != nil {
		t.Fatal(err)
	}
	input.Places[0].StayMin = 9
	if err := ValidatePlan(input); err == nil {
		t.Fatal("short stay accepted")
	}
	input.Places[0].StayMin = 60
	input.EndBy = "08:00"
	if err := ValidatePlan(input); err == nil {
		t.Fatal("end before departure accepted")
	}
}

func TestStrictClockFormat(t *testing.T) {
	if _, err := At("2026-11-14", "9:00"); err == nil {
		t.Fatal("noncanonical clock accepted")
	}
}

func TestBuildKeepsMustBeforeOptional(t *testing.T) {
	app := App{Maps: &Maps{HTTP: testHTTP(`{"routes":[{"duration":"600s"}]}`)}}
	input := PlanInput{Title: "旅", Date: "2026-11-14", Start: Start{PlaceID: "start", DepartAt: "09:00"}, EndBy: "10:20"}
	visits := []Visit{{PlaceID: "optional", Priority: "optional", StayMin: 60}, {PlaceID: "must", Priority: "must", StayMin: 60}}
	places := map[string]Place{"optional": {PlaceID: "optional", Name: "optional"}, "must": {PlaceID: "must", Name: "must"}}
	result, err := app.Build(context.Background(), input, places, visits, false)
	if err != nil || len(result.Items) != 1 || result.Items[0].PlaceID != "must" || len(result.Dropped) != 1 {
		t.Fatalf("%+v %v", result, err)
	}
	input.EndBy = "09:30"
	_, err = app.Build(context.Background(), input, places, visits, false)
	if err == nil || APIError(err).Status != 422 {
		t.Fatalf("infeasible must: %v", err)
	}
}

func TestReaddedItemNoLongerDropped(t *testing.T) {
	old := Itinerary{Dropped: []Dropped{{PlaceID: "p1", Reason: "no time"}, {PlaceID: "p2", Reason: "no time"}}}
	next := Itinerary{Items: []Item{{ItemID: "it", PlaceID: "p1"}}, Legs: []Leg{}, Dropped: []Dropped{}}
	value := joinPrefix(old, nil, next)
	if len(value.Dropped) != 1 || value.Dropped[0].PlaceID != "p2" {
		t.Fatalf("included item remains dropped: %+v", value.Dropped)
	}
}
