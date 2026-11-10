package service

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"testing"
	"time"
)

func TestTransitUnavailable(t *testing.T) {
	depart, _ := time.Parse(time.RFC3339, "2026-11-14T09:00:00+09:00")
	maps := Maps{HTTP: testHTTP(`{"routes":[{"duration":"600s"}]}`)}
	_, err := maps.Route(context.Background(), Waypoint{PlaceID: "a"}, Waypoint{PlaceID: "b"}, depart)
	if err == nil || APIError(err).Status != 503 || APIError(err).Code != "TRANSIT_UNAVAILABLE" {
		t.Fatalf("unconfigured routing: %v", err)
	}
	leg, err := maps.Route(context.Background(), Waypoint{PlaceID: "a"}, Waypoint{PlaceID: "a"}, depart)
	if err != nil || leg.DurationMin != 0 || leg.ArriveAt != leg.DepartAt {
		t.Fatalf("same point: %+v %v", leg, err)
	}
}

func transitLine(mode, name, departure, arrival string) map[string]any {
	return map[string]any{"Type": mode, "Name": name,
		"DepartureState": map[string]any{"Datetime": map[string]string{"text": departure, "operation": "today"}},
		"ArrivalState":   map[string]any{"Datetime": map[string]string{"text": arrival, "operation": "today"}}}
}

func transitResponse(lines ...map[string]any) string {
	data, _ := json.Marshal(map[string]any{"ResultSet": map[string]any{"apiVersion": "1", "engineVersion": "test", "Course": []any{map[string]any{"Route": map[string]any{"Line": lines}}}}})
	return string(data)
}

func transitHTTP(minutes int) *http.Client {
	return &http.Client{Transport: roundTripFunc(func(r *http.Request) (*http.Response, error) {
		body := `{"ResultSet":{"Condition":"rail-bus-walk"}}`
		if strings.Contains(r.URL.Path, "/search/course/") {
			depart, err := time.ParseInLocation("200601021504", r.URL.Query().Get("date")+r.URL.Query().Get("time"), JST)
			if err != nil {
				return nil, err
			}
			body = transitResponse(transitLine("train", "鉄道", depart.Format(time.RFC3339), depart.Add(time.Duration(minutes)*time.Minute).Format(time.RFC3339)))
		}
		return &http.Response{StatusCode: 200, Header: make(http.Header), Body: io.NopCloser(strings.NewReader(body))}, nil
	})}
}

func transitClient(body string, status int) *http.Client {
	return &http.Client{Transport: roundTripFunc(func(r *http.Request) (*http.Response, error) {
		if strings.Contains(r.URL.Path, "/toolbox/") {
			return testHTTP(`{"ResultSet":{"Condition":"rail-bus-walk"}}`).Transport.RoundTrip(r)
		}
		return &http.Response{StatusCode: status, Header: make(http.Header), Body: io.NopCloser(strings.NewReader(body))}, nil
	})}
}

func TestTransitRoute(t *testing.T) {
	depart, _ := time.Parse(time.RFC3339, "2026-11-14T09:00:00+09:00")
	for _, mode := range []string{"train", "bus", "walk"} {
		t.Run(mode, func(t *testing.T) {
			transit := Transit{Key: "test", HTTP: transitClient(transitResponse(transitLine(mode, "実際の路線", "2026-11-14T09:05:00+09:00", "2026-11-14T09:20:30+09:00")), 200)}
			leg, err := transit.Route(t.Context(), Point{Lat: 35, Lng: 139}, Point{Lat: 34, Lng: 135}, depart)
			if err != nil || leg.Mode != mode || leg.DurationMin != 21 || leg.DepartAt != depart.Format(time.RFC3339) || leg.ArriveAt != "2026-11-14T09:20:30+09:00" {
				t.Fatalf("leg=%+v err=%v", leg, err)
			}
			if mode != "walk" && (leg.LineName == nil || *leg.LineName != "実際の路線") {
				t.Fatalf("missing line name: %+v", leg)
			}
		})
	}
}

func TestTransitWaitAndOvernight(t *testing.T) {
	depart, _ := time.Parse(time.RFC3339, "2026-11-14T23:40:00+09:00")
	for _, datePrefix := range []string{"2026-11-14T", ""} {
		arrivalPrefix := ""
		if datePrefix != "" {
			arrivalPrefix = "2026-11-15T"
		}
		body := transitResponse(
			transitLine("walk", "徒歩", datePrefix+"23:45:00+09:00", datePrefix+"23:50:00+09:00"),
			transitLine("train", "夜行列車", datePrefix+"23:55:00+09:00", arrivalPrefix+"00:15:00+09:00"),
			transitLine("bus", "市バス", arrivalPrefix+"00:20:00+09:00", arrivalPrefix+"00:25:00+09:00"),
			transitLine("walk", "徒歩", arrivalPrefix+"00:25:00+09:00", arrivalPrefix+"00:30:00+09:00"))
		transit := Transit{Key: "test", HTTP: transitClient(body, 200)}
		leg, err := transit.Route(t.Context(), Point{Lat: 35, Lng: 139}, Point{Lat: 34, Lng: 135}, depart)
		if err != nil || leg.Mode != "train" || leg.DurationMin != 50 || leg.ArriveAt != "2026-11-15T00:30:00+09:00" || leg.LineName == nil || *leg.LineName != "夜行列車 / 市バス" {
			t.Fatalf("leg=%+v err=%v", leg, err)
		}
	}
}

func TestTransitErrors(t *testing.T) {
	depart, _ := time.Parse(time.RFC3339, "2026-11-14T09:00:00+09:00")
	valid := transitResponse(transitLine("train", "線", "2026-11-14T09:00:00+09:00", "2026-11-14T09:10:00+09:00"))
	tests := []struct {
		name, body   string
		status, want int
		code         string
	}{
		{"missing result", "{}", 200, 502, "UPSTREAM_ERROR"},
		{"invalid json", "{", 200, 502, "UPSTREAM_ERROR"},
		{"upstream body error", `{"ResultSet":{"Error":{"Message":"secret"}}}`, 200, 502, "UPSTREAM_ERROR"},
		{"no route", `{"ResultSet":{"apiVersion":"1","engineVersion":"test"}}`, 200, 422, "ROUTE_NOT_FOUND"},
		{"empty route", `{"ResultSet":{"apiVersion":"1","Course":[]}}`, 200, 422, "ROUTE_NOT_FOUND"},
		{"missing route details", `{"ResultSet":{"Course":[{}]}}`, 200, 502, "UPSTREAM_ERROR"},
		{"missing time", strings.Replace(valid, "2026-11-14T09:10:00+09:00", "", 1), 200, 502, "UPSTREAM_ERROR"},
		{"invalid time", strings.Replace(valid, "2026-11-14T09:10:00+09:00", "09:99:00+09:00", 1), 200, 502, "UPSTREAM_ERROR"},
		{"backwards time", strings.Replace(valid, "2026-11-14T09:10:00+09:00", "2026-11-14T08:59:00+09:00", 1), 200, 502, "UPSTREAM_ERROR"},
		{"before requested departure", strings.Replace(valid, "2026-11-14T09:00:00+09:00", "2026-11-14T08:59:00+09:00", 1), 200, 502, "UPSTREAM_ERROR"},
		{"unknown mode", strings.Replace(valid, `"train"`, `"unknown"`, 1), 200, 502, "UPSTREAM_ERROR"},
		{"missing mode", strings.Replace(valid, `"train"`, `""`, 1), 200, 502, "UPSTREAM_ERROR"},
		{"authentication", `{"secret":"test"}`, 403, 502, "UPSTREAM_ERROR"},
		{"throttled", `{}`, 429, 429, "RATE_LIMITED"},
	}
	for _, mode := range []string{"plane", "ship", "car", "cycle", "demand"} {
		tests = append(tests, struct {
			name, body   string
			status, want int
			code         string
		}{mode, strings.Replace(valid, `"train"`, fmt.Sprintf("%q", mode), 1), 200, 422, "ROUTE_NOT_FOUND"})
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			transit := Transit{Key: "test", HTTP: transitClient(tt.body, tt.status)}
			_, err := transit.Route(t.Context(), Point{Lat: 35, Lng: 139}, Point{Lat: 34, Lng: 135}, depart)
			if err == nil || APIError(err).Status != tt.want || APIError(err).Code != tt.code || strings.Contains(err.Error(), "secret") {
				t.Fatalf("error=%v want %d %s", err, tt.want, tt.code)
			}
		})
	}
}

func TestTransitRequestUsesJapaneseDateAndGeneratedCondition(t *testing.T) {
	var conditionCalls, routeCalls int
	transit := Transit{Key: "mixway-key", HTTP: &http.Client{Transport: roundTripFunc(func(r *http.Request) (*http.Response, error) {
		if r.URL.Host != "mixway.ekispert.jp" || r.Method != "GET" || r.Header.Get("Authorization") != "" || r.URL.Query().Get("key") != "mixway-key" {
			t.Fatalf("request: %s %s %v", r.Method, r.URL, r.Header)
		}
		q := r.URL.Query()
		body := `{"ResultSet":{"Condition":"generated-condition"}}`
		switch r.URL.Path {
		case "/v1/json/toolbox/course/condition":
			conditionCalls++
			if q.Get("plane") != "never" || q.Get("ship") != "never" {
				t.Fatalf("condition query: %v", q)
			}
		case "/v1/json/search/course/extreme":
			routeCalls++
			if q.Get("conditionDetail") != "generated-condition" || q.Get("date") != "20261115" || q.Get("time") != "0030" || q.Get("searchType") != "departure" || q.Get("viaList") != "35,139:34,135" || q.Get("maxCarDistance") != "0" || q.Get("applyMaxCarDistanceStrict") != "true" {
				t.Fatalf("route query: %v", q)
			}
			body = transitResponse(transitLine("train", "線", "2026-11-15T00:30:00+09:00", "2026-11-15T01:00:00+09:00"))
		default:
			t.Fatalf("unexpected URL %s", r.URL)
		}
		return &http.Response{StatusCode: 200, Header: make(http.Header), Body: io.NopCloser(strings.NewReader(body))}, nil
	})}}
	depart, _ := time.Parse(time.RFC3339, "2026-11-14T15:30:00Z")
	for range 2 {
		if _, err := transit.Route(t.Context(), Point{Lat: 35, Lng: 139}, Point{Lat: 34, Lng: 135}, depart); err != nil {
			t.Fatal(err)
		}
	}
	if conditionCalls != 1 || routeCalls != 2 {
		t.Fatalf("condition=%d routes=%d", conditionCalls, routeCalls)
	}
}

func TestMapsRouteReusesLocation(t *testing.T) {
	var detailCalls int
	maps := Maps{HTTP: &http.Client{Transport: roundTripFunc(func(r *http.Request) (*http.Response, error) {
		detailCalls++
		if r.URL.Host != "places.googleapis.com" || r.URL.Path != "/v1/places/b" {
			t.Fatalf("unexpected details request %s", r.URL)
		}
		return testHTTP(`{"id":"b","displayName":{"text":"終点"},"location":{"latitude":34,"longitude":135}}`).Transport.RoundTrip(r)
	})}, Transit: &Transit{Key: "test", HTTP: transitHTTP(10)}}
	depart, _ := time.Parse(time.RFC3339, "2026-11-14T09:00:00+09:00")
	from := Waypoint{PlaceID: "a", Location: Point{Lat: 35, Lng: 139}, HasLocation: true}
	to := Waypoint{PlaceID: "b"}
	leg, err := maps.Route(t.Context(), from, to, depart)
	if err != nil || leg.DurationMin != 10 || detailCalls != 1 {
		t.Fatalf("leg=%+v err=%v details=%d", leg, err, detailCalls)
	}
	to.Location, to.HasLocation = Point{Lat: 34, Lng: 135}, true
	_, err = maps.Route(t.Context(), from, to, depart)
	if err != nil || detailCalls != 1 {
		t.Fatalf("known location fetched again: details=%d err=%v", detailCalls, err)
	}
	from.Location.Lat = 100
	if _, err = maps.Route(t.Context(), from, to, depart); err == nil || APIError(err).Status != 400 {
		t.Fatalf("invalid coordinates: %v", err)
	}
}

func TestTransitChoosesActualArrival(t *testing.T) {
	depart, _ := time.Parse(time.RFC3339, "2026-11-14T09:00:00+09:00")
	slow := transitLine("train", "乗車は短いが遅い便", "2026-11-14T09:30:00+09:00", "2026-11-14T09:35:00+09:00")
	fast := transitLine("bus", "先に着く便", "2026-11-14T09:05:00+09:00", "2026-11-14T09:25:00+09:00")
	body, _ := json.Marshal(map[string]any{"ResultSet": map[string]any{"Course": []any{
		map[string]any{"Route": map[string]any{"Line": []any{slow}}},
		map[string]any{"Route": map[string]any{"Line": []any{fast}}},
	}}})
	transit := Transit{Key: "test", HTTP: transitClient(string(body), 200)}
	leg, err := transit.Route(t.Context(), Point{Lat: 35, Lng: 139}, Point{Lat: 34, Lng: 135}, depart)
	if err != nil || leg.Mode != "bus" || leg.DurationMin != 25 || leg.LineName == nil || *leg.LineName != "先に着く便" {
		t.Fatalf("leg=%+v err=%v", leg, err)
	}
}

func TestTransitConditionErrors(t *testing.T) {
	depart, _ := time.Parse(time.RFC3339, "2026-11-14T09:00:00+09:00")
	for _, body := range []string{`{}`, `{"ResultSet":{}}`, `{"ResultSet":{"Condition":"unused","Error":{"Message":"secret"}}}`} {
		transit := Transit{Key: "test", HTTP: testHTTP(body)}
		_, err := transit.Route(t.Context(), Point{Lat: 35, Lng: 139}, Point{Lat: 34, Lng: 135}, depart)
		if err == nil || APIError(err).Status != 502 || strings.Contains(err.Error(), "secret") {
			t.Fatalf("condition=%s err=%v", body, err)
		}
	}
}

func TestTransitIntercityPlan(t *testing.T) {
	tokyo := Point{Lat: 35.6812, Lng: 139.7671}
	shinOsaka := Point{Lat: 34.7335, Lng: 135.5002}
	castle := Place{PlaceID: "castle", Name: "大阪城", Location: Point{Lat: 34.6873, Lng: 135.5262}}
	client := &http.Client{Transport: roundTripFunc(func(r *http.Request) (*http.Response, error) {
		minutes := 30
		if strings.HasPrefix(r.URL.Query().Get("viaList"), "35.6812,139.7671:") {
			minutes = 180
		}
		return transitHTTP(minutes).Transport.RoundTrip(r)
	})}
	app := App{Maps: &Maps{Transit: &Transit{Key: "test", HTTP: client}}}
	visit := Visit{PlaceID: castle.PlaceID, Priority: "must", StayMin: 60}
	input := PlanInput{Title: "東京から大阪へ", Date: "2026-11-14", Start: Start{Location: &tokyo, Name: "東京駅", DepartAt: "09:00"}, End: End{Location: &shinOsaka, Name: "新大阪駅", ArriveBy: "17:00"}, Places: []Visit{visit}}
	trip, err := app.Build(t.Context(), input, map[string]Place{castle.PlaceID: castle}, input.Places, BuildOptions{})
	if err != nil || len(trip.Items) != 1 || len(trip.Legs) != 2 || trip.Summary.MoveMin != 210 || trip.End.ArriveAt != "2026-11-14T13:30:00+09:00" {
		t.Fatalf("trip=%+v err=%v", trip, err)
	}
	for _, leg := range trip.Legs {
		if leg.Mode != "train" {
			t.Fatalf("intercity trip lost public transit: %+v", leg)
		}
	}
}

func TestTransitDetailedMode(t *testing.T) {
	depart, _ := time.Parse(time.RFC3339, "2026-11-14T09:00:00+09:00")
	for _, test := range []struct{ mode, detail, name string }{
		{"bus", "local", "都営バス"},
		{"train", "shinkansen", "ＪＲ新幹線のぞみ"},
	} {
		t.Run(test.detail, func(t *testing.T) {
			line := transitLine(test.mode, test.name, "2026-11-14T09:05:00+09:00", "2026-11-14T09:20:00+09:00")
			line["Type"] = map[string]string{"text": test.mode, "detail": test.detail}
			transit := Transit{Key: "test", HTTP: transitClient(transitResponse(line), 200)}
			leg, err := transit.Route(t.Context(), Point{Lat: 35, Lng: 139}, Point{Lat: 34, Lng: 135}, depart)
			if err != nil || leg.Mode != test.mode || leg.DurationMin != 20 || leg.LineName == nil || *leg.LineName != test.name {
				t.Fatalf("leg=%+v err=%v", leg, err)
			}
		})
	}
}
