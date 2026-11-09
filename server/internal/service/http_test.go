package service

import (
	"net/http/httptest"
	"strings"
	"testing"
)

func TestDecodeRejectsInvalidBody(t *testing.T) {
	for _, body := range []string{`{"text":"ok","extra":1}`, `{"text":"ok"} {}`, `null`, `{"text":`} {
		t.Run(body, func(t *testing.T) {
			r := httptest.NewRequest("POST", "/", strings.NewReader(body))
			r.Header.Set("Content-Type", "application/json")
			var input struct {
				Text string `json:"text"`
			}
			if Decode(httptest.NewRecorder(), r, &input) == nil {
				t.Fatal("invalid body was accepted")
			}
		})
	}
}

func TestCoordinates(t *testing.T) {
	for _, query := range []string{"lat=91&lng=0", "lat=0", "lng=0", "lat=NaN&lng=0", "lat=0&lng=181"} {
		r := httptest.NewRequest("GET", "/?"+query, nil)
		if _, err := Coordinates(r); err == nil {
			t.Fatalf("accepted %s", query)
		}
	}
	r := httptest.NewRequest("GET", "/?lat=0&lng=0", nil)
	point, err := Coordinates(r)
	if err != nil || point == nil || point.Lat != 0 {
		t.Fatalf("zero coordinates: %v, %v", point, err)
	}
}

func TestIfMatch(t *testing.T) {
	for _, value := range []string{"", "0", "-1", "*", `W/"2"`, `"2`, "2,3"} {
		r := httptest.NewRequest("PUT", "/", nil)
		r.Header.Set("If-Match", value)
		if _, err := Version(r); err == nil {
			t.Fatalf("accepted %q", value)
		}
	}
	for _, value := range []string{"2", `"2"`} {
		r := httptest.NewRequest("PUT", "/", nil)
		r.Header.Set("If-Match", value)
		if version, err := Version(r); err != nil || version != 2 {
			t.Fatalf("valid version: %d, %v", version, err)
		}
	}
}

func TestTextLimitCountsWhitespace(t *testing.T) {
	if Text(strings.Repeat(" ", 100)+"a", 1, 100) {
		t.Fatal("overlong input accepted after trimming")
	}
	if Text("   ", 1, 100) {
		t.Fatal("blank input accepted")
	}
	if !Text("東京駅", 1, 100) {
		t.Fatal("UTF-8 input rejected")
	}
}
