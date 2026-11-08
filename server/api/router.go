package api

import (
	"net/http"
	"sort"
	"strings"

	"github.com/create-alt/gen-TLE/server/api/itineraries"
	"github.com/create-alt/gen-TLE/server/api/itineraries/replans"
	"github.com/create-alt/gen-TLE/server/api/me"
	"github.com/create-alt/gen-TLE/server/api/places"
	"github.com/create-alt/gen-TLE/server/internal/service"
)

// New は API のルートを登録する。番号は API 仕様（2026-11-06 改訂版）の #1〜#16。
//
// パスごとに1つのハンドラーを登録し、その中で HTTP メソッドを振り分ける。
// "GET /places/{placeId}" と "/places/interpret" のように、メソッド付きの
// パターンとメソッドなしのパターンを混ぜると net/http が衝突として扱うため。
func New(app *service.App) http.Handler {
	routes := []struct {
		Method, Path string
		Handler      http.HandlerFunc
	}{
		{"GET", "/healthz", Healthz},
		{"GET", "/places/autocomplete", places.Autocomplete(app)},                             // #1
		{"POST", "/places/interpret", places.Interpret(app)},                                  // #2
		{"POST", "/itineraries", itineraries.Create(app)},                                     // #3
		{"GET", "/me/itineraries", me.Itineraries(app)},                                       // #4
		{"GET", "/itineraries/{id}", itineraries.Get(app)},                                    // #5
		{"PUT", "/itineraries/{id}/places", itineraries.UpdatePlaces(app)},                    // #6
		{"POST", "/itineraries/{id}/replans", replans.Create(app)},                            // #7
		{"GET", "/itineraries/{id}/replans/{replanId}/explanation", replans.Explanation(app)}, // #8
		{"POST", "/itineraries/{id}/replans/{replanId}/accept", replans.Accept(app)},          // #9
		{"GET", "/itineraries/{id}/suggestions", itineraries.Suggestions(app)},                // #10
		{"POST", "/itineraries/{id}/items", itineraries.AddItem(app)},                         // #11
		{"GET", "/places/nearby", places.Nearby(app)},                                         // #12
		{"GET", "/places/{placeId}", places.Detail(app)},                                      // #13
		{"PATCH", "/itineraries/{id}", itineraries.Rename(app)},                               // #14
		{"DELETE", "/itineraries/{id}", itineraries.Delete(app)},                              // #15
		{"POST", "/itineraries/{id}/copy", itineraries.Copy(app)},                             // #16
	}
	queries := map[string][]string{
		"/places/autocomplete":                             {"q", "lat", "lng"},
		"/places/nearby":                                   {"lat", "lng", "radius", "q"},
		"/places/{placeId}":                                {"date"},
		"/me/itineraries":                                  {"limit", "cursor"},
		"/itineraries/{id}/suggestions":                    {"from", "to", "afterItemId"},
		"/itineraries/{id}/replans/{replanId}/explanation": {"optionId"},
	}
	handlers := map[string]map[string]http.HandlerFunc{}
	for _, route := range routes {
		if handlers[route.Path] == nil {
			handlers[route.Path] = map[string]http.HandlerFunc{}
		}
		handlers[route.Path][route.Method] = route.Handler
	}
	mux := http.NewServeMux()
	for path, byMethod := range handlers {
		allowed := []string{}
		for method := range byMethod {
			allowed = append(allowed, method)
		}
		sort.Strings(allowed)
		mux.HandleFunc(path, func(w http.ResponseWriter, r *http.Request) {
			method := r.Method
			if method == http.MethodHead && byMethod[http.MethodGet] != nil {
				method = http.MethodGet
			}
			handler, ok := byMethod[method]
			if !ok {
				w.Header().Set("Allow", strings.Join(allowed, ", "))
				service.WriteError(w, service.Fail(405, "METHOD_NOT_ALLOWED", "HTTPメソッドが不正です"))
				return
			}
			if _, err := service.Query(r, queries[path]...); err != nil {
				service.WriteError(w, err)
				return
			}
			handler(w, r)
		})
	}
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) { service.WriteError(w, service.NotFound()) })
	protected := app.Auth(mux)
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/healthz" && (r.Method == http.MethodGet || r.Method == http.MethodHead) {
			mux.ServeHTTP(w, r)
			return
		}
		protected.ServeHTTP(w, r)
	})
}
