package service

import (
	"context"
	"io"
	"net/http"
	"strings"
	"testing"
)

func TestUpstreamErrors(t *testing.T) {
	for _, status := range []int{429, 500, 200} {
		t.Run(http.StatusText(status), func(t *testing.T) {
			client := &http.Client{Transport: roundTripFunc(func(r *http.Request) (*http.Response, error) {
				return &http.Response{StatusCode: status, Body: io.NopCloser(strings.NewReader("not json")), Header: make(http.Header)}, nil
			})}
			var output any
			err := Request(context.Background(), client, "GET", "https://example.test", nil, nil, &output)
			if err == nil {
				t.Fatal("invalid response was accepted")
			}
			want := "UPSTREAM_ERROR"
			if status == 429 {
				want = "RATE_LIMITED"
			}
			if APIError(err).Code != want {
				t.Fatalf("got %v, want %s", err, want)
			}
		})
	}
}

func TestRequestCancellation(t *testing.T) {
	ctx, cancel := context.WithCancel(context.Background())
	cancel()
	if err := Request(ctx, &http.Client{}, "GET", "http://localhost", nil, nil, new(any)); err == nil {
		t.Fatal("canceled request succeeded")
	}
}
