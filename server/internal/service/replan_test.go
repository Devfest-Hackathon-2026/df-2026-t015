package service

import (
	"context"
	"encoding/json"
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
	trip := Itinerary{Date: "2026-11-14", Start: Start{PlaceID: ref("start"), DepartAt: "2026-11-14T09:00:00+09:00"}, End: End{PlaceID: ref("start"), ArriveBy: "17:00"}, Items: []Item{{ItemID: "a", EndAt: "2026-11-14T12:00:00+09:00"}}}
	from, _ := time.Parse(time.RFC3339, "2026-11-14T11:00:00+09:00")
	to := from.Add(time.Hour)
	if _, err := app.Suggest(t.Context(), trip, from, to, "a"); err == nil || APIError(err).Status != 400 {
		t.Fatalf("occupied time accepted: %v", err)
	}
}

// placesHTTP は Places Details に ID どおりの施設を返し、検索は空にする偽のクライアント。
func placesHTTP() *http.Client {
	return &http.Client{Transport: roundTripFunc(func(r *http.Request) (*http.Response, error) {
		body := `{}`
		switch {
		case strings.Contains(r.URL.Path, "searchText"), strings.Contains(r.URL.Path, "searchNearby"):
			body = `{"places":[]}`
		case strings.HasPrefix(r.URL.Path, "/v1/places/"):
			id := strings.TrimPrefix(r.URL.Path, "/v1/places/")
			body = `{"id":"` + id + `","displayName":{"text":"` + id + `"},"location":{"latitude":35,"longitude":139}}`
		}
		return &http.Response{StatusCode: 200, Header: make(http.Header), Body: io.NopCloser(strings.NewReader(body))}, nil
	})}
}

func geminiReturning(text string) *Gemini {
	return &Gemini{HTTP: testHTTP(`{"candidates":[{"content":{"parts":[{"text":` + strconv.Quote(text) + `}]},"finishReason":"STOP"}]}`)}
}

func TestReplanKeepsAlgorithmOptionsWhenAIIsInvalid(t *testing.T) {
	trip := Itinerary{ID: "trip", Version: 1, Title: "旅", Date: "2026-11-14", Start: Start{PlaceID: ref("start"), DepartAt: "2026-11-14T09:00:00+09:00"}, End: End{PlaceID: ref("start"), ArriveBy: "17:00"},
		Items: []Item{{ItemID: "a", PlaceID: "p1", Priority: "must", StartAt: "2026-11-14T09:00:00+09:00", EndAt: "2026-11-14T10:00:00+09:00", StayMin: 60}, {ItemID: "b", PlaceID: "p2", Priority: "want", StartAt: "2026-11-14T10:10:00+09:00", EndAt: "2026-11-14T11:10:00+09:00", StayMin: 60}},
		Legs:  []Leg{{FromItemID: "a", ToItemID: "b", DurationMin: 10}}}
	for _, malformed := range []string{`{}`, `null`, `{"options":[{"placeIds":null}]}`, `{"options":[{"label":"x","placeIds":["invented"]}]}`, `not json`} {
		app := App{Maps: &Maps{HTTP: routesHTTP(placesHTTP(), 10)}, AI: geminiReturning(malformed)}
		delay := 20
		result, err := app.Replan(context.Background(), trip, ReplanInput{CurrentItemID: "a", DelayMin: &delay})
		if err != nil {
			t.Fatalf("%s: %v", malformed, err)
		}
		if len(result.Options) != 2 {
			t.Fatalf("%s: %+v", malformed, result.Options)
		}
		for _, option := range result.Options {
			if option.Source != "algorithm" {
				t.Fatalf("%s: invalid AI option accepted: %+v", malformed, option)
			}
		}
	}
}

func TestLowestPriority(t *testing.T) {
	visits := []Visit{{PlaceID: "a", Priority: "must"}, {PlaceID: "b", Priority: "want", StayMin: 90}, {PlaceID: "c", Priority: "optional", StayMin: 30}, {PlaceID: "d", Priority: "optional", StayMin: 60}}
	if got := lowestPriority(visits); got != 3 {
		t.Fatalf("got %d", got)
	}
	if got := lowestPriority(visits[:1]); got != -1 {
		t.Fatalf("must only: %d", got)
	}
}

func TestExplanationFactsAndReasons(t *testing.T) {
	before := Item{ItemID: "b", PlaceID: "p2", Name: "海の美術館", Priority: "want", StartAt: "2026-11-14T11:00:00+09:00", StayMin: 60}
	after := before
	after.StartAt = "2026-11-14T11:40:00+09:00"
	option := Option{OptionID: "op", Label: "時刻をずらす", Source: "algorithm", Changes: []Change{{Type: "retime", ItemID: "b", Before: &before, After: &after}, {Type: "keep", ItemID: "c", Before: &before, After: &before}}}
	facts := ExplanationFacts(Replan{Warnings: []Warning{{Type: "miss_transit", Message: "バスに間に合いません"}}}, option)
	changes := facts["changes"].([]changeFact)
	if len(changes) != 2 || *changes[0].ShiftMin != 40 || changes[0].AfterStart != "11:40" {
		t.Fatalf("%+v", changes)
	}
	app := App{AI: geminiReturning(`{"summary":"40分遅らせました。","reasons":[{"itemId":"b","reason":"遅れに合わせました。"},{"itemId":"c","reason":"keep は対象外"}]}`)}
	result, err := app.Explain(context.Background(), Replan{}, option)
	if err != nil || result.Status != "ready" || len(result.Reasons) != 1 || result.Reasons[0].Type != "retime" {
		t.Fatalf("%+v %v", result, err)
	}
}
func TestReplanRetimesAbsorbedDelay(t *testing.T) {
	trip := Itinerary{ID: "trip", Version: 1, Date: "2026-11-14", End: End{PlaceID: ref("end"), Name: "駅", ArriveBy: "17:00"}, Items: []Item{{ItemID: "a", PlaceID: "p1", StartAt: "2026-11-14T09:00:00+09:00", EndAt: "2026-11-14T10:00:00+09:00", StayMin: 60}, {ItemID: "b", PlaceID: "p2", StartAt: "2026-11-14T11:00:00+09:00", EndAt: "2026-11-14T12:00:00+09:00", StayMin: 60}}, Legs: []Leg{{ToItemID: "b", DurationMin: 10}}}
	app := App{Maps: &Maps{HTTP: routesHTTP(placesHTTP(), 10)}}
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
	app := App{Maps: &Maps{HTTP: routesHTTP(client, 10)}, AI: &Gemini{HTTP: testHTTP(`{"candidates":[{"content":{"parts":[{"text":"{}"}]},"finishReason":"STOP"}]}`)}}
	trip := Itinerary{Date: "2026-11-14", Start: Start{PlaceID: ref("start"), DepartAt: "2026-11-14T09:00:00+09:00"}, End: End{PlaceID: ref("start"), ArriveBy: "17:00"}}
	from, _ := time.Parse(time.RFC3339, "2026-11-14T10:00:00+09:00")
	if _, err := app.Suggest(t.Context(), trip, from, from.Add(time.Hour), ""); err == nil || APIError(err).Status != 502 {
		t.Fatalf("missing AI suggestions field accepted: %v", err)
	}
}

func TestReplanWarnsWhenEndPlaceIsLate(t *testing.T) {
	trip := Itinerary{ID: "trip", Version: 1, Date: "2026-11-14", End: End{PlaceID: ref("end"), Name: "駅", ArriveBy: "10:20", ArriveAt: "2026-11-14T10:10:00+09:00"},
		Items: []Item{{ItemID: "a", PlaceID: "p1", StartAt: "2026-11-14T09:00:00+09:00", EndAt: "2026-11-14T10:00:00+09:00", StayMin: 60}},
		Legs:  []Leg{{FromItemID: "a", ToItemID: "end", DurationMin: 10, DepartAt: "2026-11-14T10:00:00+09:00", ArriveAt: "2026-11-14T10:10:00+09:00"}}}
	delay := 30
	result, err := (&App{Maps: &Maps{HTTP: routesHTTP(placesHTTP(), 10)}}).Replan(context.Background(), trip, ReplanInput{CurrentItemID: "a", DelayMin: &delay})
	if err != nil || len(result.Options) != 1 {
		t.Fatalf("%+v %v", result, err)
	}
	next := result.Options[0].Candidate
	if next.End.ArriveAt != "2026-11-14T10:40:00+09:00" || next.Legs[0].DepartAt != "2026-11-14T10:30:00+09:00" || next.Summary.EndAt != next.End.ArriveAt {
		t.Fatalf("end leg not shifted: %+v %+v", next.Legs, next.End)
	}
	if len(result.Warnings) != 1 || result.Warnings[0].Type != "end_at_risk" {
		t.Fatalf("warnings: %+v", result.Warnings)
	}
	if trip.Legs[0].DepartAt != "2026-11-14T10:00:00+09:00" {
		t.Fatal("input legs mutated")
	}
}

func TestReplanReturnsAtMostFiveOptions(t *testing.T) {
	trip := Itinerary{ID: "trip", Version: 1, Title: "旅", Date: "2026-11-14", Start: Start{PlaceID: ref("start"), DepartAt: "2026-11-14T09:00:00+09:00"}, End: End{PlaceID: ref("start"), ArriveBy: "17:00"},
		Items: []Item{{ItemID: "a", PlaceID: "p1", Priority: "must", StartAt: "2026-11-14T09:00:00+09:00", EndAt: "2026-11-14T10:00:00+09:00", StayMin: 60}, {ItemID: "b", PlaceID: "p2", Priority: "want", StartAt: "2026-11-14T10:10:00+09:00", EndAt: "2026-11-14T11:10:00+09:00", StayMin: 60}, {ItemID: "c", PlaceID: "p3", Priority: "optional", StartAt: "2026-11-14T11:20:00+09:00", EndAt: "2026-11-14T12:20:00+09:00", StayMin: 60}},
		Legs:  []Leg{{FromItemID: "a", ToItemID: "b", DurationMin: 10}}}
	// AI がスキーマを超えて4案、しかもすべて異なる案を返しても、AI の案は3案までにする。
	ai := `{"options":[{"label":"1","placeIds":["p3","p2"]},{"label":"2","placeIds":["p3"]},{"label":"3","placeIds":["p2"]},{"label":"4","placeIds":[]}]}`
	app := App{Maps: &Maps{HTTP: routesHTTP(placesHTTP(), 10)}, AI: geminiReturning(ai)}
	delay := 20
	result, err := app.Replan(context.Background(), trip, ReplanInput{CurrentItemID: "a", DelayMin: &delay})
	if err != nil || len(result.Options) > MaxReplanOptions {
		t.Fatalf("%d options: %v", len(result.Options), err)
	}
	counts := map[string]int{}
	for _, option := range result.Options {
		counts[option.Source]++
	}
	if counts["algorithm"] != 2 || counts["ai"] < 1 || counts["ai"] > MaxAIReplanOptions {
		t.Fatalf("%v", counts)
	}
}

func TestReplanSkipsAIOptionWhosePlaceCannotBeLoaded(t *testing.T) {
	trip := Itinerary{ID: "trip", Version: 1, Title: "旅", Date: "2026-11-14", Start: Start{PlaceID: ref("start"), DepartAt: "2026-11-14T09:00:00+09:00"}, End: End{PlaceID: ref("start"), ArriveBy: "17:00"},
		Items: []Item{{ItemID: "a", PlaceID: "p1", Priority: "must", StartAt: "2026-11-14T09:00:00+09:00", EndAt: "2026-11-14T10:00:00+09:00", StayMin: 60}, {ItemID: "b", PlaceID: "p2", Priority: "want", StartAt: "2026-11-14T10:10:00+09:00", EndAt: "2026-11-14T11:10:00+09:00", StayMin: 60}},
		Legs:  []Leg{{FromItemID: "a", ToItemID: "b", DurationMin: 10}}}
	client := &http.Client{Transport: roundTripFunc(func(r *http.Request) (*http.Response, error) {
		status, body := 200, `{}`
		switch {
		case strings.Contains(r.URL.Path, "searchText"):
			body = `{"places":[{"id":"broken","displayName":{"text":"代替施設"},"location":{"latitude":35,"longitude":139}}]}`
		case r.URL.Path == "/v1/places/broken":
			// AI が選んだ代替施設の詳細取得が失敗する。
			status, body = 500, `{}`
		case strings.HasPrefix(r.URL.Path, "/v1/places/"):
			id := strings.TrimPrefix(r.URL.Path, "/v1/places/")
			body = `{"id":"` + id + `","displayName":{"text":"` + id + `"},"location":{"latitude":35,"longitude":139}}`
		}
		return &http.Response{StatusCode: status, Header: make(http.Header), Body: io.NopCloser(strings.NewReader(body))}, nil
	})}
	app := App{Maps: &Maps{HTTP: routesHTTP(client, 10)}, AI: geminiReturning(`{"options":[{"label":"代替施設へ","placeIds":["broken"]}]}`)}
	delay := 20
	result, err := app.Replan(context.Background(), trip, ReplanInput{CurrentItemID: "a", DelayMin: &delay})
	if err != nil || len(result.Options) != 2 || result.Options[0].Source != "algorithm" || result.Options[1].Source != "algorithm" {
		t.Fatalf("%+v %v", result.Options, err)
	}
}

func TestSuggestChecksOnwardTransitFromTheActualDeparture(t *testing.T) {
	from, _ := time.Parse(time.RFC3339, "2026-11-14T13:00:00+09:00")
	client := &http.Client{Transport: roundTripFunc(func(r *http.Request) (*http.Response, error) {
		body := ""
		switch {
		case strings.Contains(r.URL.Path, "searchNearby"):
			body = `{"places":[{"id":"cafe","displayName":{"text":"港のカフェ"},"location":{"latitude":35.001,"longitude":139},"primaryTypeDisplayName":{"text":"カフェ"}}]}`
		case strings.HasPrefix(r.URL.Path, "/v1/places/"):
			id := strings.TrimPrefix(r.URL.Path, "/v1/places/")
			body = `{"id":"` + id + `","displayName":{"text":"` + id + `"},"location":{"latitude":35,"longitude":139}}`
		case r.URL.Host == "routes.googleapis.com":
			var request routeRequest
			if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
				return nil, err
			}
			// 徒歩・車は50分。カフェからの公共交通は、空き時間の開始（13:00）に出ると次の便まで待つため50分、
			// 滞在後に出れば5分。それ以外の公共交通は5分。
			body = routeBody(50 * 60)
			if request.Mode == "TRANSIT" {
				seconds := 5 * 60
				if departure, _ := time.Parse(time.RFC3339, request.Departure); request.Origin.lat() == 35.001 && departure.Equal(from) {
					seconds = 50 * 60
				}
				body = transitBody(seconds, "HEAVY_RAIL", "鉄道")
			}
		}
		return &http.Response{StatusCode: 200, Header: make(http.Header), Body: io.NopCloser(strings.NewReader(body))}, nil
	})}
	app := App{Maps: &Maps{HTTP: client}, AI: geminiReturning(`{"ideas":[],"suggestions":[{"placeId":"cafe","reason":"港を眺めて休憩できる","stayMin":30}]}`)}
	trip := Itinerary{Date: "2026-11-14", Start: Start{PlaceID: ref("start"), DepartAt: "2026-11-14T09:00:00+09:00"}, End: End{PlaceID: ref("start"), ArriveBy: "17:00"},
		Items: []Item{{ItemID: "a", PlaceID: "p1", StartAt: "2026-11-14T12:00:00+09:00", EndAt: "2026-11-14T13:00:00+09:00"}, {ItemID: "b", PlaceID: "p2", StartAt: "2026-11-14T14:00:00+09:00", EndAt: "2026-11-14T15:00:00+09:00"}}}
	result, err := app.Suggest(context.Background(), trip, from, from.Add(time.Hour), "a")
	if err != nil || len(result.Suggestions) != 1 || result.Suggestions[0].LegToNext.DurationMin != 5 {
		t.Fatalf("%+v %v", result, err)
	}
}

func TestEditAcceptsFixedItemExtendedByDelay(t *testing.T) {
	// 300分の滞在が遅延で520分に延びた滞在中の予定。⑥ では全件を送り直すので、その値のまま受け付ける。
	trip := Itinerary{ID: "trip", Version: 2, Title: "旅", Date: "2026-11-14", ExpiresAt: "2026-12-14T00:00:00+09:00",
		Start: Start{PlaceID: ref("start"), Name: "start", Location: &Point{Lat: 35, Lng: 139}, DepartAt: "2026-11-14T08:00:00+09:00"},
		End:   End{PlaceID: ref("start"), Name: "start", Location: &Point{Lat: 35, Lng: 139}, ArriveBy: "20:00"},
		Items: []Item{{ItemID: "a", PlaceID: "p1", Name: "p1", Priority: "must", StayMin: 520, Status: "current", StartAt: "2026-11-14T08:10:00+09:00", EndAt: "2026-11-14T16:50:00+09:00"}}}
	app := App{Maps: &Maps{HTTP: routesHTTP(placesHTTP(), 10)}}
	value, err := app.Edit(context.Background(), trip, EditInput{Places: []Visit{{PlaceID: "p1", Priority: "must", StayMin: 520}}})
	if err != nil || len(value.Items) != 1 || value.Items[0].StayMin != 520 || value.End.ArriveAt != "2026-11-14T17:00:00+09:00" {
		t.Fatalf("%+v %v", value, err)
	}
	// 新しく追加する行き先は、これまでどおり480分までにする。
	if _, err := app.Edit(context.Background(), trip, EditInput{Places: []Visit{{PlaceID: "p1", Priority: "must", StayMin: 520}, {PlaceID: "p2", Priority: "want", StayMin: 500}}}); err == nil || APIError(err).Status != 400 {
		t.Fatalf("long new stay accepted: %v", err)
	}
	// 滞在中の予定の滞在時間を変えることはできない。
	if _, err := app.Edit(context.Background(), trip, EditInput{Places: []Visit{{PlaceID: "p1", Priority: "must", StayMin: 490}}}); err == nil || APIError(err).Status != 400 {
		t.Fatalf("changed fixed stay accepted: %v", err)
	}
}
