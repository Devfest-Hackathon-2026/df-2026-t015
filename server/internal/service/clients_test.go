package service

import (
	"context"
	"io"
	"net/http"
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
