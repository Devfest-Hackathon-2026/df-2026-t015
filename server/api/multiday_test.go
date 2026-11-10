package api

import (
	"context"
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"

	"github.com/create-alt/gen-TLE/server/internal/service"
)

func TestOvernightCreateAndCopy(t *testing.T) {
	store := &flowStore{}
	client := &http.Client{Transport: flowTransport{}}
	app := &service.App{Store: store, Verify: func(context.Context, string) (string, error) { return "owner", nil }, Maps: &service.Maps{HTTP: client, Transit: &service.Transit{Key: "test", HTTP: client}}}
	handler := New(app)
	call := func(path, body string) service.Itinerary {
		t.Helper()
		request := httptest.NewRequest("POST", path, strings.NewReader(body))
		request.Header.Set("Authorization", "Bearer test")
		request.Header.Set("Content-Type", "application/json")
		response := httptest.NewRecorder()
		handler.ServeHTTP(response, request)
		if response.Code != 201 {
			t.Fatalf("%s: %d %s", path, response.Code, response.Body.String())
		}
		var output service.Itinerary
		if err := json.Unmarshal(response.Body.Bytes(), &output); err != nil {
			t.Fatal(err)
		}
		return output
	}
	trip := call("/itineraries", `{"title":"深夜の旅行","date":"2026-11-20","start":{"placeId":"start","departAt":"23:40"},"end":{"placeId":"end","date":"2026-11-21","arriveBy":"01:00"},"places":[{"placeId":"p1","priority":"must","stayMin":30}]}`)
	if trip.End.Date != "2026-11-21" || trip.End.ArriveAt != "2026-11-21T00:30:00+09:00" || trip.ExpiresAt != "2026-12-21T00:00:00+09:00" {
		t.Fatalf("overnight result: %+v", trip)
	}
	copy := call("/itineraries/trip/copy", `{"date":"2026-12-01"}`)
	if copy.Date != "2026-12-01" || copy.End.Date != "2026-12-02" || copy.End.ArriveAt != "2026-12-02T00:30:00+09:00" {
		t.Fatalf("copy result: %+v", copy)
	}
}
