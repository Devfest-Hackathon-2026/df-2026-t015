package service

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"strings"
	"sync"
	"testing"
	"time"
)

type routeRequest struct {
	Origin      routeEndpoint `json:"origin"`
	Destination routeEndpoint `json:"destination"`
	Mode        string        `json:"travelMode"`
	Departure   string        `json:"departureTime"`
}

type routeEndpoint struct {
	PlaceID  string `json:"placeId"`
	Location *struct {
		LatLng struct {
			Latitude float64 `json:"latitude"`
		} `json:"latLng"`
	} `json:"location"`
}

func (e routeEndpoint) lat() float64 {
	if e.Location == nil {
		return 0
	}
	return e.Location.LatLng.Latitude
}

func routeBody(seconds int) string {
	return fmt.Sprintf(`{"routes":[{"duration":"%ds"}]}`, seconds)
}

func transitBody(seconds int, vehicle, line string) string {
	return fmt.Sprintf(`{"routes":[{"duration":"%ds","legs":[{"steps":[{},{"transitDetails":{"transitLine":{"name":%q,"vehicle":{"type":%q}}}}]}]}]}`, seconds, line, vehicle)
}

// fakeRoutes は Routes API の computeRoutes に、移動手段ごとに answer の応答を返す。
// それ以外の URL は base に渡す（nil なら空の JSON）。
func fakeRoutes(base *http.Client, answer func(routeRequest) (int, string)) *http.Client {
	return &http.Client{Transport: roundTripFunc(func(r *http.Request) (*http.Response, error) {
		if r.URL.Host != "routes.googleapis.com" {
			if base == nil {
				return testHTTP(`{}`).Transport.RoundTrip(r)
			}
			return base.Transport.RoundTrip(r)
		}
		var request routeRequest
		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
			return nil, err
		}
		status, body := answer(request)
		return &http.Response{StatusCode: status, Header: make(http.Header), Body: io.NopCloser(strings.NewReader(body))}, nil
	})}
}

// routesHTTP は徒歩・車とも minutes 分の経路を返し、公共交通は結果なし（日本の実際の応答）にする。
// minutes が負なら、どの移動手段も経路なしにする。
func routesHTTP(base *http.Client, minutes int) *http.Client {
	return fakeRoutes(base, func(request routeRequest) (int, string) {
		if minutes < 0 || request.Mode == "TRANSIT" {
			return 200, `{}`
		}
		return 200, routeBody(minutes * 60)
	})
}

func TestRouteChoosesMode(t *testing.T) {
	depart, _ := time.Parse(time.RFC3339, "2026-11-14T09:00:00+09:00")
	from, to := Waypoint{PlaceID: "a"}, Waypoint{PlaceID: "b"}
	for _, test := range []struct {
		name                 string
		walk, drive, transit string
		mode                 string
		minutes              int
		line                 string
	}{
		{"短い徒歩", routeBody(20 * 60), routeBody(5 * 60), transitBody(10*60, "SUBWAY", "銀座線"), "walk", 20, ""},
		{"長い徒歩は公共交通", routeBody(90 * 60), routeBody(30 * 60), transitBody(40*60, "HEAVY_RAIL", "ＪＲ"), "train", 40, "ＪＲ"},
		{"バスだけの公共交通", routeBody(90 * 60), routeBody(30 * 60), transitBody(45*60, "BUS", "都営バス"), "bus", 45, "都営バス"},
		{"公共交通なしは車", routeBody(90 * 60), routeBody(30 * 60), `{}`, "taxi", 30, ""},
		{"徒歩だけの公共交通は使わない", routeBody(90 * 60), routeBody(30 * 60), routeBody(80 * 60), "taxi", 30, ""},
		{"車もなければ長い徒歩", routeBody(90 * 60), `{}`, `{}`, "walk", 90, ""},
		{"秒は切り上げる", routeBody(10*60 + 1), routeBody(60), `{}`, "walk", 11, ""},
	} {
		t.Run(test.name, func(t *testing.T) {
			maps := Maps{HTTP: fakeRoutes(nil, func(request routeRequest) (int, string) {
				return 200, map[string]string{"WALK": test.walk, "DRIVE": test.drive, "TRANSIT": test.transit}[request.Mode]
			})}
			leg, err := maps.Route(t.Context(), from, to, depart)
			if err != nil || leg.Mode != test.mode || leg.DurationMin != test.minutes || leg.DepartAt != depart.Format(time.RFC3339) || leg.ArriveAt != depart.Add(time.Duration(test.minutes)*time.Minute).Format(time.RFC3339) {
				t.Fatalf("leg=%+v err=%v", leg, err)
			}
			if (test.line == "") != (leg.LineName == nil) || leg.LineName != nil && *leg.LineName != test.line {
				t.Fatalf("line=%v", leg.LineName)
			}
		})
	}
}

func TestRouteTransitIncludesWaiting(t *testing.T) {
	depart, _ := time.Parse(time.RFC3339, "2026-11-14T09:00:00+09:00")
	maps := Maps{HTTP: fakeRoutes(nil, func(request routeRequest) (int, string) {
		if request.Mode == "TRANSIT" {
			return 200, `{"routes":[{"duration":"600s","legs":[{"steps":[{"transitDetails":{"transitLine":{"nameShort":"京王線","vehicle":{"type":"HEAVY_RAIL"}},"stopDetails":{"arrivalTime":"2026-11-14T00:35:00Z"}}}]}]}]}`
		}
		return 200, routeBody(3 * 60 * 60)
	})}
	leg, err := maps.Route(t.Context(), Waypoint{PlaceID: "a"}, Waypoint{PlaceID: "b"}, depart)
	if err != nil || leg.Mode != "train" || leg.DurationMin != 35 || *leg.LineName != "京王線" {
		t.Fatalf("leg=%+v err=%v", leg, err)
	}
}

func TestRouteRequests(t *testing.T) {
	depart, _ := time.Parse(time.RFC3339, "2026-11-14T09:00:00+09:00")
	var mu sync.Mutex
	seen := map[string]routeRequest{}
	masks := map[string]string{}
	maps := Maps{Key: "maps-key", HTTP: &http.Client{Transport: roundTripFunc(func(r *http.Request) (*http.Response, error) {
		var request routeRequest
		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
			return nil, err
		}
		if r.URL.String() != "https://routes.googleapis.com/directions/v2:computeRoutes" || r.Header.Get("X-Goog-Api-Key") != "maps-key" {
			t.Errorf("request %s %v", r.URL, r.Header)
		}
		mu.Lock()
		seen[request.Mode], masks[request.Mode] = request, r.Header.Get("X-Goog-FieldMask")
		mu.Unlock()
		return testHTTP(routeBody(600)).Transport.RoundTrip(r)
	})}}
	from := Waypoint{PlaceID: "a"}
	to := Waypoint{PlaceID: "b", Location: Point{Lat: 34, Lng: 135}, HasLocation: true}
	if _, err := maps.Route(t.Context(), from, to, depart); err != nil {
		t.Fatal(err)
	}
	if len(seen) != 3 {
		t.Fatalf("modes=%v", seen)
	}
	for mode, request := range seen {
		// 座標が分かっている地点は座標で、そうでなければ placeId で送る。
		if request.Origin.PlaceID != "a" || request.Destination.PlaceID != "" || request.Destination.lat() != 34 {
			t.Fatalf("%s request=%+v", mode, request)
		}
		if (mode == "TRANSIT") != (request.Departure == "2026-11-14T00:00:00Z") || (mode == "TRANSIT") != strings.Contains(masks[mode], "transitDetails") {
			t.Fatalf("%s departure=%q mask=%q", mode, request.Departure, masks[mode])
		}
	}
}

func TestRouteErrors(t *testing.T) {
	depart, _ := time.Parse(time.RFC3339, "2026-11-14T09:00:00+09:00")
	from, to := Waypoint{PlaceID: "a"}, Waypoint{PlaceID: "b"}
	answer := func(walk, drive, transit int, body string) *http.Client {
		return fakeRoutes(nil, func(request routeRequest) (int, string) {
			return map[string]int{"WALK": walk, "DRIVE": drive, "TRANSIT": transit}[request.Mode], body
		})
	}
	for _, test := range []struct {
		name   string
		client *http.Client
		status int
		code   string
	}{
		{"経路なし", routesHTTP(nil, -1), 422, "ROUTE_NOT_FOUND"},
		{"すべて失敗", answer(500, 500, 500, `{}`), 502, "UPSTREAM_ERROR"},
		{"呼び出し上限", answer(429, 429, 200, `{}`), 429, "RATE_LIMITED"},
		{"不正な所要時間", answer(200, 200, 200, `{"routes":[{"duration":"x"}]}`), 502, "UPSTREAM_ERROR"},
	} {
		t.Run(test.name, func(t *testing.T) {
			_, err := (&Maps{HTTP: test.client}).Route(t.Context(), from, to, depart)
			if err == nil || APIError(err).Status != test.status || APIError(err).Code != test.code {
				t.Fatalf("err=%v", err)
			}
		})
	}
	// 公共交通や徒歩が失敗しても、車の経路があれば使う。
	client := fakeRoutes(nil, func(request routeRequest) (int, string) {
		if request.Mode == "DRIVE" {
			return 200, routeBody(600)
		}
		return 500, `{}`
	})
	leg, err := (&Maps{HTTP: client}).Route(t.Context(), from, to, depart)
	if err != nil || leg.Mode != "taxi" || leg.DurationMin != 10 {
		t.Fatalf("leg=%+v err=%v", leg, err)
	}
}

func TestRouteSamePointAndInvalidLocation(t *testing.T) {
	depart, _ := time.Parse(time.RFC3339, "2026-11-14T09:00:00+09:00")
	maps := Maps{HTTP: &http.Client{Transport: roundTripFunc(func(r *http.Request) (*http.Response, error) {
		t.Fatalf("unexpected request %s", r.URL)
		return nil, nil
	})}}
	leg, err := maps.Route(t.Context(), Waypoint{PlaceID: "a"}, Waypoint{PlaceID: "a"}, depart)
	if err != nil || leg.DurationMin != 0 || leg.ArriveAt != leg.DepartAt {
		t.Fatalf("same point: %+v %v", leg, err)
	}
	invalid := Waypoint{Location: Point{Lat: 100, Lng: 139}, HasLocation: true}
	if _, err := maps.Route(t.Context(), invalid, Waypoint{PlaceID: "b"}, depart); err == nil || APIError(err).Status != 400 {
		t.Fatalf("invalid coordinates: %v", err)
	}
}

func TestIntercityPlanUsesCar(t *testing.T) {
	tokyo := Point{Lat: 35.6812, Lng: 139.7671}
	shinOsaka := Point{Lat: 34.7335, Lng: 135.5002}
	castle := Place{PlaceID: "castle", Name: "大阪城", Location: Point{Lat: 34.6873, Lng: 135.5262}}
	client := fakeRoutes(nil, func(request routeRequest) (int, string) {
		switch request.Mode {
		case "TRANSIT":
			return 200, `{}`
		case "WALK":
			return 200, routeBody(100 * 60 * 60)
		}
		if request.Origin.lat() == tokyo.Lat {
			return 200, routeBody(180 * 60)
		}
		return 200, routeBody(30 * 60)
	})
	app := App{Maps: &Maps{HTTP: client}}
	visit := Visit{PlaceID: castle.PlaceID, Priority: "must", StayMin: 60}
	input := PlanInput{Title: "東京から大阪へ", Date: "2026-11-14", Start: Start{Location: &tokyo, Name: "東京駅", DepartAt: "09:00"}, End: End{Location: &shinOsaka, Name: "新大阪駅", ArriveBy: "17:00"}, Places: []Visit{visit}}
	trip, err := app.Build(t.Context(), input, map[string]Place{castle.PlaceID: castle}, input.Places, BuildOptions{})
	if err != nil || len(trip.Items) != 1 || len(trip.Legs) != 2 || trip.Summary.MoveMin != 210 || trip.End.ArriveAt != "2026-11-14T13:30:00+09:00" {
		t.Fatalf("trip=%+v err=%v", trip, err)
	}
	for _, leg := range trip.Legs {
		if leg.Mode != "taxi" {
			t.Fatalf("intercity trip should use the car route: %+v", leg)
		}
	}
}
