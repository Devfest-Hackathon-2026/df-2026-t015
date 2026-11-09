package api

import (
	"net/http/httptest"
	"testing"
)

func TestPublicStripsBasePath(t *testing.T) {
	handler := Public(New(testApp()), PublicOptions{BasePath: "/api"})
	for _, test := range []struct {
		path   string
		token  string
		status int
	}{
		{"/api/healthz", "", 200},
		{"/healthz", "", 200},
		{"/api/itineraries/trip", "owner", 200},
		{"/api/itineraries/trip", "", 401},
		{"/itineraries/trip", "owner", 200},
		{"/apix/healthz", "", 401},
	} {
		r := httptest.NewRequest("GET", test.path, nil)
		if test.token != "" {
			r.Header.Set("Authorization", "Bearer "+test.token)
		}
		w := httptest.NewRecorder()
		handler.ServeHTTP(w, r)
		if w.Code != test.status {
			t.Errorf("%s: %d %s", test.path, w.Code, w.Body.String())
		}
	}
}

func TestPublicCORS(t *testing.T) {
	handler := Public(New(testApp()), PublicOptions{BasePath: "/api", AllowedOrigins: []string{"https://gen-tle.web.app", "http://localhost:*"}})
	preflight := func(origin string) *httptest.ResponseRecorder {
		r := httptest.NewRequest("OPTIONS", "/api/itineraries/trip", nil)
		r.Header.Set("Origin", origin)
		r.Header.Set("Access-Control-Request-Method", "PUT")
		r.Header.Set("Access-Control-Request-Headers", "authorization, content-type, if-match")
		w := httptest.NewRecorder()
		handler.ServeHTTP(w, r)
		return w
	}
	for _, origin := range []string{"https://gen-tle.web.app", "http://localhost:51234", "http://localhost"} {
		w := preflight(origin)
		if w.Code != 204 || w.Header().Get("Access-Control-Allow-Origin") != origin || w.Header().Get("Access-Control-Allow-Headers") == "" {
			t.Errorf("%s: %d %v", origin, w.Code, w.Header())
		}
	}
	for _, origin := range []string{"https://evil.example", "http://localhost.evil.example:8080", "https://localhost:443"} {
		if w := preflight(origin); w.Header().Get("Access-Control-Allow-Origin") != "" {
			t.Errorf("allowed %s", origin)
		}
	}
	r := httptest.NewRequest("GET", "/api/itineraries/trip", nil)
	r.Header.Set("Origin", "https://gen-tle.web.app")
	r.Header.Set("Authorization", "Bearer owner")
	w := httptest.NewRecorder()
	handler.ServeHTTP(w, r)
	if w.Code != 200 || w.Header().Get("Access-Control-Allow-Origin") != "https://gen-tle.web.app" || w.Header().Get("Access-Control-Expose-Headers") != "ETag, Retry-After" || w.Header().Get("ETag") == "" {
		t.Fatalf("%d %v", w.Code, w.Header())
	}
	// CORS を設定しなければ、ヘッダーは付けない。
	plain := Public(New(testApp()), PublicOptions{})
	r = httptest.NewRequest("GET", "/healthz", nil)
	r.Header.Set("Origin", "https://gen-tle.web.app")
	w = httptest.NewRecorder()
	plain.ServeHTTP(w, r)
	if w.Header().Get("Access-Control-Allow-Origin") != "" {
		t.Fatal("CORS header without configuration")
	}
}

func TestPublicOptionsFromEnv(t *testing.T) {
	t.Setenv("API_BASE_PATH", " /api/ \r")
	t.Setenv("CORS_ALLOWED_ORIGINS", "https://gen-tle.web.app/, http://localhost:*\r,")
	options := PublicOptionsFromEnv()
	if options.BasePath != "/api" || len(options.AllowedOrigins) != 2 || options.AllowedOrigins[0] != "https://gen-tle.web.app" || options.AllowedOrigins[1] != "http://localhost:*" {
		t.Fatalf("%+v", options)
	}
}
