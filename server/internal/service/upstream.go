package service

import (
	"bytes"
	"context"
	"encoding/json"
	"io"
	"log"
	"net/http"
	"time"
)

func Request(ctx context.Context, client *http.Client, method, url string, headers map[string]string, input, output any) error {
	var body []byte
	var err error
	if input != nil {
		body, err = json.Marshal(input)
		if err != nil {
			return Upstream()
		}
	}
	ctx, cancel := context.WithTimeout(ctx, 15*time.Second)
	defer cancel()
	r, err := http.NewRequestWithContext(ctx, method, url, bytes.NewReader(body))
	if err != nil {
		return Upstream()
	}
	r.Header.Set("Content-Type", "application/json; charset=utf-8")
	for name, value := range headers {
		r.Header.Set(name, value)
	}
	response, err := client.Do(r)
	if err != nil {
		log.Printf("upstream %s %s: %v", method, r.URL.Host+r.URL.Path, err)
		return Upstream()
	}
	defer response.Body.Close()
	if response.StatusCode < 200 || response.StatusCode >= 300 {
		detail, _ := io.ReadAll(io.LimitReader(response.Body, 1024))
		log.Printf("upstream %s %s: HTTP %d: %s", method, r.URL.Host+r.URL.Path, response.StatusCode, bytes.TrimSpace(detail))
	}
	if response.StatusCode == 429 {
		return Fail(429, "RATE_LIMITED", "外部サービスの呼び出し上限に達しました")
	}
	if response.StatusCode < 200 || response.StatusCode >= 300 {
		return Upstream()
	}
	data, err := io.ReadAll(io.LimitReader(response.Body, (2<<20)+1))
	if err != nil || len(data) > 2<<20 || json.Unmarshal(data, output) != nil {
		log.Printf("upstream %s %s: invalid response body", method, r.URL.Host+r.URL.Path)
		return Upstream()
	}
	return nil
}
