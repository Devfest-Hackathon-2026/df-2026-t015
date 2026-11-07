package service

import (
	"context"
	"testing"
	"time"
)

func ref(value string) *string { return &value }

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
	input := PlanInput{Title: "旅", Date: "2026-11-14", Start: Start{PlaceID: ref("start"), DepartAt: "09:00"}, End: End{PlaceID: ref("start"), ArriveBy: "17:00"}, Places: []Visit{{PlaceID: "a", Priority: "must", StayMin: 60}}}
	if err := ValidatePlan(input); err != nil {
		t.Fatal(err)
	}
	input.Places[0].StayMin = 9
	if err := ValidatePlan(input); err == nil {
		t.Fatal("short stay accepted")
	}
	input.Places[0].StayMin = 60
	input.End.ArriveBy = "08:00"
	if err := ValidatePlan(input); err == nil {
		t.Fatal("end before departure accepted")
	}
	input.End = End{Location: &Point{Lat: 35, Lng: 139}, Name: "駅前", ArriveBy: "17:00"}
	if err := ValidatePlan(input); err != nil {
		t.Fatalf("map point rejected: %v", err)
	}
	input.End.Name = ""
	if err := ValidatePlan(input); err == nil {
		t.Fatal("map point without name accepted")
	}
	input.End = End{PlaceID: ref("end"), Location: &Point{Lat: 35, Lng: 139}, ArriveBy: "17:00"}
	if err := ValidatePlan(input); err == nil {
		t.Fatal("both placeId and location accepted")
	}
}

func TestStrictClockFormat(t *testing.T) {
	if _, err := At("2026-11-14", "9:00"); err == nil {
		t.Fatal("noncanonical clock accepted")
	}
}

func TestBuildKeepsMustBeforeOptional(t *testing.T) {
	app := App{Maps: &Maps{HTTP: testHTTP(`{"routes":[{"duration":"600s"}]}`)}}
	// 移動は各10分。出発地 → must（60分）→ 終わる場所で 10:20 に着く。
	input := PlanInput{Title: "旅", Date: "2026-11-14", Start: Start{PlaceID: ref("start"), DepartAt: "09:00"}, End: End{PlaceID: ref("end"), Name: "駅", ArriveBy: "10:20"}}
	visits := []Visit{{PlaceID: "optional", Priority: "optional", StayMin: 60}, {PlaceID: "must", Priority: "must", StayMin: 60}}
	places := map[string]Place{"optional": {PlaceID: "optional", Name: "optional"}, "must": {PlaceID: "must", Name: "must"}}
	result, err := app.Build(context.Background(), input, places, visits, BuildOptions{})
	if err != nil || len(result.Items) != 1 || result.Items[0].PlaceID != "must" || len(result.Dropped) != 1 {
		t.Fatalf("%+v %v", result, err)
	}
	last := result.Legs[len(result.Legs)-1]
	if last.ToItemID != "end" || last.FromItemID != result.Items[0].ItemID || result.End.ArriveAt != "2026-11-14T10:20:00+09:00" || result.Summary.EndAt != result.End.ArriveAt {
		t.Fatalf("leg to the end place: %+v %+v", result.Legs, result.End)
	}
	input.End.ArriveBy = "09:50"
	_, err = app.Build(context.Background(), input, places, visits, BuildOptions{})
	if APIError(err).Code != "MUST_ITEMS_INFEASIBLE" {
		t.Fatalf("infeasible must: %v", err)
	}
	input.End.ArriveBy = "09:05"
	_, err = app.Build(context.Background(), input, places, visits, BuildOptions{})
	if APIError(err).Code != "END_INFEASIBLE" {
		t.Fatalf("unreachable end: %v", err)
	}
	late, err := app.Build(context.Background(), input, places, visits, BuildOptions{DropMust: true, LateEnd: true})
	if err != nil || len(late.Items) != 0 || len(late.Dropped) != 2 || late.End.ArriveAt != "2026-11-14T09:10:00+09:00" {
		t.Fatalf("late end for replans: %+v %v", late, err)
	}
}

func TestReaddedItemNoLongerDropped(t *testing.T) {
	old := Itinerary{Dropped: []Dropped{{PlaceID: "p1", Reason: "no time"}, {PlaceID: "p2", Reason: "no time"}}}
	next := Itinerary{Items: []Item{{ItemID: "it", PlaceID: "p1"}}, Legs: []Leg{}, Dropped: []Dropped{}}
	value := joinPrefix(old, nil, next, Start{})
	if len(value.Dropped) != 1 || value.Dropped[0].PlaceID != "p2" {
		t.Fatalf("included item remains dropped: %+v", value.Dropped)
	}
}

func TestDayHours(t *testing.T) {
	saturday := time.Date(2026, 11, 14, 0, 0, 0, 0, JST)
	regular := &Hours{Periods: []Period{
		{Open: HourPoint{Day: 6, Hour: 9}, Close: &HourPoint{Day: 6, Hour: 12}},
		{Open: HourPoint{Day: 6, Hour: 14}, Close: &HourPoint{Day: 6, Hour: 18, Minute: 30}},
		{Open: HourPoint{Day: 5, Hour: 18}, Close: &HourPoint{Day: 6, Hour: 2}},
	}}
	if hours := DayHours(nil, regular, saturday); hours == nil || hours.OpensAt != "09:00" || hours.ClosesAt != "18:30" {
		t.Fatalf("split day: %+v", hours)
	}
	if hours := DayHours(nil, regular, saturday.AddDate(0, 0, -1)); hours == nil || hours.OpensAt != "18:00" || hours.ClosesAt != "02:00" {
		t.Fatalf("overnight: %+v", hours)
	}
	if hours := DayHours(nil, regular, saturday.AddDate(0, 0, 1)); hours != nil {
		t.Fatalf("closed day: %+v", hours)
	}
	if hours := DayHours(nil, &Hours{Periods: []Period{{Open: HourPoint{Day: 0}}}}, saturday); hours == nil || hours.ClosesAt != "24:00" {
		t.Fatalf("always open: %+v", hours)
	}
	// 直近7日は currentOpeningHours を優先し、区間がない日は臨時休業として扱う。
	today := time.Now().In(JST)
	special := HourPoint{Day: int(today.Weekday()), Hour: 11}
	special.Date = &struct {
		Year  int `json:"year"`
		Month int `json:"month"`
		Day   int `json:"day"`
	}{today.Year(), int(today.Month()), today.Day()}
	current := &Hours{Periods: []Period{{Open: special, Close: &HourPoint{Day: int(today.Weekday()), Hour: 15}}}}
	if hours := DayHours(current, regular, today); hours == nil || hours.OpensAt != "11:00" || hours.ClosesAt != "15:00" {
		t.Fatalf("special hours: %+v", hours)
	}
	if hours := DayHours(current, &Hours{Periods: []Period{{Open: HourPoint{Day: int(today.AddDate(0, 0, 1).Weekday()), Hour: 9}, Close: &HourPoint{Day: int(today.AddDate(0, 0, 1).Weekday()), Hour: 17}}}}, today.AddDate(0, 0, 1)); hours != nil {
		t.Fatalf("closed by current hours: %+v", hours)
	}
}
