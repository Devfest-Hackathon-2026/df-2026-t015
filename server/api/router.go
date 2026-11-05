package api

import (
	"net/http"
	"strings"

	"github.com/create-alt/gen-TLE/server/api/itineraries"
	"github.com/create-alt/gen-TLE/server/api/itineraries/replans"
	"github.com/create-alt/gen-TLE/server/api/me"
	"github.com/create-alt/gen-TLE/server/api/places"
	"github.com/create-alt/gen-TLE/server/internal/service"
)

func New(app *service.App) http.Handler {
	mux := http.NewServeMux()
	routes := []struct {
		Method, Path string
		Handler      http.HandlerFunc
	}{
		{"GET", "/healthz", Healthz},
		{"GET", "/places/autocomplete", places.Autocomplete(app)},
		{"POST", "/places/interpret", places.Interpret(app)},
		{"POST", "/itineraries", itineraries.Create(app)},
		{"GET", "/me/itineraries", me.Itineraries(app)},
		{"GET", "/itineraries/{id}", itineraries.Get(app)},
		{"PUT", "/itineraries/{id}/places", itineraries.UpdatePlaces(app)},
		{"POST", "/itineraries/{id}/replans", replans.Create(app)},
		{"GET", "/itineraries/{id}/replans/{replanId}/explanation", replans.Explanation(app)},
		{"POST", "/itineraries/{id}/replans/{replanId}/accept", replans.Accept(app)},
		{"GET", "/itineraries/{id}/suggestions", itineraries.Suggestions(app)},
		{"POST", "/itineraries/{id}/items", itineraries.AddItem(app)},
	}
	methods := map[string][]string{}
	queries := map[string][]string{
		"/places/autocomplete":                             {"q", "lat", "lng"},
		"/itineraries/{id}/suggestions":                    {"from", "to", "afterItemId"},
		"/itineraries/{id}/replans/{replanId}/explanation": {"optionId"},
	}
	for _, route := range routes {
		mux.HandleFunc(route.Method+" "+route.Path, func(w http.ResponseWriter, r *http.Request) {
			if _, err := service.Query(r, queries[route.Path]...); err != nil {
				service.WriteError(w, err)
				return
			}
			route.Handler(w, r)
		})
		methods[route.Path] = append(methods[route.Path], route.Method)
	}
	for path, allowed := range methods {
		mux.HandleFunc(path, func(w http.ResponseWriter, r *http.Request) {
			w.Header().Set("Allow", strings.Join(allowed, ", "))
			service.WriteError(w, service.Fail(405, "METHOD_NOT_ALLOWED", "HTTPメソッドが不正です"))
		})
	}
	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) { service.WriteError(w, service.NotFound()) })
	protected := app.Auth(mux)
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		if r.URL.Path == "/healthz" && (r.Method == "GET" || r.Method == "HEAD") {
			mux.ServeHTTP(w, r)
			return
		}
		protected.ServeHTTP(w, r)
	})
}
