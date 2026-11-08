package api

import (
	"context"
	"encoding/json"
	"errors"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/create-alt/gen-TLE/server/internal/service"
)

type testStore struct {
	service.Store
	trip service.Itinerary
	err  error
}

func (s *testStore) Allow(context.Context, string) error { return nil }
func (s *testStore) Get(ctx context.Context, uid, id string) (service.Itinerary, error) {
	if uid != "owner" {
		return service.Itinerary{}, service.NotFound()
	}
	return s.trip, s.err
}
func (s *testStore) List(context.Context, string, int, string) (service.ItineraryPage, error) {
	return service.ItineraryPage{Itineraries: []service.ItineraryEntry{}}, nil
}

func testApp() *service.App {
	return &service.App{Store: &testStore{trip: service.Itinerary{ID: "trip", Version: 3}}, Verify: func(ctx context.Context, token string) (string, error) {
		if token == "bad" {
			return "", errors.New("invalid token")
		}
		return token, nil
	}}
}

func TestAllProtectedRoutes(t *testing.T) {
	routes := []string{"GET /places/autocomplete?q=a", "POST /places/interpret", "POST /itineraries", "GET /me/itineraries", "GET /itineraries/trip", "PUT /itineraries/trip/places", "POST /itineraries/trip/replans", "GET /itineraries/trip/replans/rp/explanation?optionId=op", "POST /itineraries/trip/replans/rp/accept", "GET /itineraries/trip/suggestions", "POST /itineraries/trip/items", "GET /places/nearby?lat=35&lng=139", "GET /places/p1", "PATCH /itineraries/trip", "DELETE /itineraries/trip", "POST /itineraries/trip/copy"}
	handler := New(testApp())
	for _, route := range routes {
		t.Run(route, func(t *testing.T) {
			method, path, _ := strings.Cut(route, " ")
			w := httptest.NewRecorder()
			handler.ServeHTTP(w, httptest.NewRequest(method, path, nil))
			if w.Code != 401 {
				t.Fatalf("status %d: %s", w.Code, w.Body.String())
			}
			var body struct{ Error struct{ Code string } }
			if json.Unmarshal(w.Body.Bytes(), &body) != nil || body.Error.Code != "UNAUTHENTICATED" {
				t.Fatal(w.Body.String())
			}
		})
	}
}

func TestHealthAndOwnedItinerary(t *testing.T) {
	handler := New(testApp())
	for _, test := range []struct {
		path, token string
		status      int
	}{{"/healthz", "", 200}, {"/itineraries/trip", "owner", 200}, {"/itineraries/trip", "other", 404}, {"/itineraries/trip", "bad", 401}, {"/missing", "owner", 404}} {
		r := httptest.NewRequest("GET", test.path, nil)
		if test.token != "" {
			r.Header.Set("Authorization", "Bearer "+test.token)
		}
		w := httptest.NewRecorder()
		handler.ServeHTTP(w, r)
		if w.Code != test.status || !strings.HasPrefix(w.Header().Get("Content-Type"), "application/json") {
			t.Fatalf("%s %s: %d %s", test.path, test.token, w.Code, w.Body.String())
		}
		if test.path == "/itineraries/trip" && test.status == 200 && w.Header().Get("ETag") != `"3"` {
			t.Fatal("ETag missing")
		}
	}
}

func TestBadRequestsDoNotCallUpstream(t *testing.T) {
	for _, test := range []struct{ method, path, body string }{
		{"GET", "/places/autocomplete?q=", ""},
		{"GET", "/places/autocomplete?q=a&lat=90", ""},
		{"POST", "/places/interpret", `{"text":""}`},
		{"POST", "/itineraries", `{}`},
		{"PUT", "/itineraries/trip/places", `{"places":[]}`},
		{"POST", "/itineraries/trip/replans", `{"currentItemId":"x","delayMin":1,"now":"2026-11-05T12:00:00+09:00"}`},
		{"POST", "/itineraries/trip/items", `{}`},
		{"GET", "/itineraries/trip/suggestions?from=no&to=no", ""},
		{"GET", "/me/itineraries?limit=0", ""},
		{"GET", "/places/nearby?lat=35", ""},
		{"GET", "/places/nearby?lat=35&lng=139&radius=99", ""},
		{"GET", "/places/nearby?lat=35&lng=139&radius=5001", ""},
		{"GET", "/places/nearby?lat=35&lng=139&q=", ""},
		{"GET", "/places/p1?date=2026-13-01", ""},
		{"POST", "/itineraries/trip/copy", `{}`},
		{"POST", "/itineraries/trip/copy", `{"date":"2026-12-12","title":""}`},
		{"GET", "/me/itineraries?limit=51", ""},
		{"POST", "/itineraries", `{"title":"旅","date":"2026-11-14","start":{"placeId":"s","departAt":"09:00"},"endBy":"17:00","places":[{"placeId":"p1","priority":"must","stayMin":60}]}`},
		{"POST", "/itineraries", `{"title":"旅","date":"2026-11-14","start":{"location":{"lat":35,"lng":139},"departAt":"09:00"},"end":{"placeId":"s","arriveBy":"17:00"},"places":[{"placeId":"p1","priority":"must","stayMin":60}]}`},
	} {
		r := httptest.NewRequest(test.method, test.path, strings.NewReader(test.body))
		r.Header.Set("Authorization", "Bearer owner")
		r.Header.Set("Content-Type", "application/json")
		w := httptest.NewRecorder()
		New(testApp()).ServeHTTP(w, r)
		if w.Code != http.StatusBadRequest {
			t.Fatalf("%s %s: %d %s", test.method, test.path, w.Code, w.Body.String())
		}
	}
}

func TestRejectsMalformedOrRepeatedQuery(t *testing.T) {
	app := testApp()
	app.Maps = &service.Maps{HTTP: &http.Client{Transport: flowTransport{}}}
	for _, query := range []string{"q=a&lat=%ZZ", "q=a&q=b", "q=a&unexpected=1"} {
		r := httptest.NewRequest("GET", "/places/autocomplete?"+query, nil)
		r.Header.Set("Authorization", "Bearer owner")
		w := httptest.NewRecorder()
		New(app).ServeHTTP(w, r)
		if w.Code != 400 {
			t.Errorf("accepted %s: %d", query, w.Code)
		}
	}
}

func TestPatchAndDeleteRequireVersionAndTitle(t *testing.T) {
	for _, test := range []struct{ method, body, version string }{
		{"PATCH", `{"title":"旅"}`, ""},
		{"PATCH", `{"title":""}`, "3"},
		{"PATCH", `{"title":"` + strings.Repeat("あ", 101) + `"}`, "3"},
		{"DELETE", "", ""},
	} {
		r := httptest.NewRequest(test.method, "/itineraries/trip", strings.NewReader(test.body))
		r.Header.Set("Authorization", "Bearer owner")
		r.Header.Set("Content-Type", "application/json")
		if test.version != "" {
			r.Header.Set("If-Match", test.version)
		}
		w := httptest.NewRecorder()
		New(testApp()).ServeHTTP(w, r)
		if w.Code != 400 {
			t.Fatalf("%s %s: %d %s", test.method, test.body, w.Code, w.Body.String())
		}
	}
}

func TestWrongMethodIsJSON405(t *testing.T) {
	for _, route := range []string{"GET /places/interpret", "POST /places/autocomplete", "PUT /itineraries/trip", "GET /itineraries/trip/copy"} {
		method, path, _ := strings.Cut(route, " ")
		r := httptest.NewRequest(method, path, nil)
		r.Header.Set("Authorization", "Bearer owner")
		w := httptest.NewRecorder()
		New(testApp()).ServeHTTP(w, r)
		var body struct{ Error struct{ Code string } }
		if w.Code != 405 || json.Unmarshal(w.Body.Bytes(), &body) != nil || body.Error.Code != "METHOD_NOT_ALLOWED" || w.Header().Get("Allow") == "" {
			t.Fatalf("%s: %d %s", route, w.Code, w.Body.String())
		}
	}
}

func TestTitleLengthIsSharedAcrossCreateRenameAndCopy(t *testing.T) {
	long := strings.Repeat("あ", 100)
	if err := service.ValidateTitle(long); err != nil {
		t.Fatalf("100 characters rejected: %v", err)
	}
	if err := service.ValidateTitle(long + "あ"); err == nil {
		t.Fatal("101 characters accepted")
	}
}
