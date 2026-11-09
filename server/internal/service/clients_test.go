package service

import (
	"context"
	"io"
	"net/http"
	"os"
	"strings"
	"testing"
)

type roundTripFunc func(*http.Request) (*http.Response, error)

func (f roundTripFunc) RoundTrip(r *http.Request) (*http.Response, error) { return f(r) }

func testHTTP(body string) *http.Client {
	return &http.Client{Transport: roundTripFunc(func(r *http.Request) (*http.Response, error) {
		return &http.Response{StatusCode: 200, Body: io.NopCloser(strings.NewReader(body)), Header: make(http.Header)}, nil
	})}
}

func TestAutocomplete(t *testing.T) {
	maps := Maps{HTTP: testHTTP(`{"suggestions":[{"placePrediction":{"placeId":"p1","structuredFormat":{"mainText":{"text":"公園"},"secondaryText":{"text":"東京都"}}}}]}`)}
	places, err := maps.Autocomplete(context.Background(), "公", &Point{Lat: 35, Lng: 139})
	if err != nil || len(places) != 1 || places[0].Name != "公園" || places[0].Address != "東京都" {
		t.Fatalf("places=%+v err=%v", places, err)
	}
}

func TestGeminiRejectsEmptyAndInvalidJSON(t *testing.T) {
	for _, body := range []string{`{"candidates":[]}`, `{"candidates":[{"content":{"parts":[{"text":"invalid"}]}}]}`, `{"candidates":[{"content":{"parts":[{"text":"{} {}"}]}}]}`} {
		ai := Gemini{HTTP: testHTTP(body), Model: "test"}
		var output struct {
			Text string `json:"text"`
		}
		if err := ai.Ask(context.Background(), Prompt{Task: "test"}, ObjectSchema(map[string]any{"text": map[string]any{"type": "string"}}), &output); err == nil {
			t.Fatalf("accepted %s", body)
		}
	}
}

func TestMapsRejectsMissingLocation(t *testing.T) {
	maps := Maps{HTTP: testHTTP(`{"id":"p1","displayName":{"text":"施設"}}`)}
	if _, err := maps.Details(context.Background(), "p1"); err == nil {
		t.Fatal("missing location was converted to 0,0")
	}
}

func TestGeminiStructuredResponse(t *testing.T) {
	ai := Gemini{HTTP: testHTTP(`{"candidates":[{"content":{"parts":[{"text":"{\"text\":\"理由\"}"}]},"finishReason":"STOP"}]}`), Model: "test"}
	var output struct {
		Text string `json:"text"`
	}
	if err := ai.Ask(context.Background(), Prompt{Task: "test"}, ObjectSchema(map[string]any{"text": map[string]any{"type": "string"}}), &output); err != nil || output.Text != "理由" {
		t.Fatalf("output=%+v err=%v", output, err)
	}
}

func TestGeminiUsesVertexAIWithoutAPIKey(t *testing.T) {
	var gotURL, apiKey, userProject string
	client := &http.Client{Transport: roundTripFunc(func(r *http.Request) (*http.Response, error) {
		gotURL, apiKey, userProject = r.URL.String(), r.Header.Get("x-goog-api-key"), r.Header.Get("X-Goog-User-Project")
		body := `{"candidates":[{"content":{"parts":[{"text":"{\"text\":\"ok\"}"}]},"finishReason":"STOP"}]}`
		return &http.Response{StatusCode: 200, Body: io.NopCloser(strings.NewReader(body)), Header: make(http.Header)}, nil
	})}
	for _, test := range []struct{ location, want string }{
		{"global", "https://aiplatform.googleapis.com/v1/projects/gen-tle/locations/global/publishers/google/models/gemini-3.5-flash:generateContent"},
		{"asia-northeast1", "https://asia-northeast1-aiplatform.googleapis.com/v1/projects/gen-tle/locations/asia-northeast1/publishers/google/models/gemini-3.5-flash:generateContent"},
	} {
		ai := Gemini{Model: "gemini-3.5-flash", Project: "gen-tle", Location: test.location, HTTP: client}
		var output struct {
			Text string `json:"text"`
		}
		if err := ai.Ask(context.Background(), Prompt{Task: "t"}, ObjectSchema(map[string]any{"text": map[string]any{"type": "string"}}), &output); err != nil || output.Text != "ok" {
			t.Fatalf("output=%+v err=%v", output, err)
		}
		if gotURL != test.want || apiKey != "" || userProject != "gen-tle" {
			t.Fatalf("url=%s key=%q project=%q", gotURL, apiKey, userProject)
		}
	}
	keyed := Gemini{Key: "k", Model: "gemini-3.5-flash"}
	if url, headers := keyed.endpoint(); url != "https://generativelanguage.googleapis.com/v1beta/models/gemini-3.5-flash:generateContent" || headers["x-goog-api-key"] != "k" {
		t.Fatalf("api key endpoint: %s %v", url, headers)
	}
}

func TestMapsHeadersWithoutAPIKeyUseQuotaProject(t *testing.T) {
	adc := Maps{Project: "gen-tle"}
	headers := adc.headers("places.id")
	if _, ok := headers["X-Goog-Api-Key"]; ok || headers["X-Goog-User-Project"] != "gen-tle" || headers["X-Goog-FieldMask"] != "places.id" {
		t.Fatalf("%v", headers)
	}
	keyed := Maps{Key: "k", Project: "gen-tle"}
	if headers := keyed.headers("places.id"); headers["X-Goog-Api-Key"] != "k" || headers["X-Goog-User-Project"] != "" {
		t.Fatalf("%v", headers)
	}
}

func TestEnvTrimsCarriageReturn(t *testing.T) {
	t.Setenv("GEMINI_MODEL", "gemini-3.5-flash\r")
	if got := env("GEMINI_MODEL"); got != "gemini-3.5-flash" {
		t.Fatalf("%q", got)
	}
}

func TestPortAndLibraryEnvTrimCarriageReturn(t *testing.T) {
	t.Setenv("PORT", "9090\r")
	if got := Port(); got != "9090" {
		t.Fatalf("port %q", got)
	}
	t.Setenv("PORT", "")
	if got := Port(); got != "8080" {
		t.Fatalf("default port %q", got)
	}
	t.Setenv("GOOGLE_APPLICATION_CREDENTIALS", "/path/key.json\r")
	cleanLibraryEnv()
	if got := os.Getenv("GOOGLE_APPLICATION_CREDENTIALS"); got != "/path/key.json" {
		t.Fatalf("credentials path %q", got)
	}
}
