package service

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"os"
	"strings"
	"time"

	firebase "firebase.google.com/go/v4"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/google"
)

// env は環境変数を前後の空白・改行（CRLF の \r を含む）を除いて読む。
func env(name string) string { return strings.TrimSpace(os.Getenv(name)) }

// cloudScope は ADC で Vertex AI・Places・Routes を呼ぶときのスコープ。
const cloudScope = "https://www.googleapis.com/auth/cloud-platform"

func Connect(ctx context.Context) (*App, func() error, error) {
	for _, key := range []string{"FIREBASE_PROJECT_ID", "GEMINI_MODEL"} {
		if env(key) == "" {
			return nil, nil, fmt.Errorf("%s を設定してください", key)
		}
	}
	project := env("FIREBASE_PROJECT_ID")
	app, err := firebase.NewApp(ctx, &firebase.Config{ProjectID: project})
	if err != nil {
		return nil, nil, err
	}
	auth, err := app.Auth(ctx)
	if err != nil {
		return nil, nil, err
	}
	db, err := app.Firestore(ctx)
	if err != nil {
		return nil, nil, err
	}
	client := &http.Client{Timeout: 15 * time.Second}
	mapsKey, geminiKey := env("GOOGLE_MAPS_API_KEY"), env("GEMINI_API_KEY")
	mapsClient, aiClient := client, client
	// API キーがない（組織のポリシーで作れないなど）ときは、ADC のトークンで呼ぶ。
	if mapsKey == "" || geminiKey == "" {
		credentials, err := google.FindDefaultCredentials(ctx, cloudScope)
		if err != nil {
			db.Close()
			return nil, nil, fmt.Errorf("API キーがない場合は ADC が必要です（gcloud auth application-default login）: %w", err)
		}
		authed := &http.Client{Timeout: 15 * time.Second, Transport: &oauth2.Transport{Source: credentials.TokenSource, Base: http.DefaultTransport}}
		if mapsKey == "" {
			mapsClient = authed
		}
		if geminiKey == "" {
			aiClient = authed
		}
	}
	location := env("GOOGLE_CLOUD_LOCATION")
	if location == "" {
		location = "global"
	}
	ai := &Gemini{Key: geminiKey, Model: env("GEMINI_MODEL"), HTTP: aiClient, Project: project, Location: location}
	maps := &Maps{Key: mapsKey, HTTP: mapsClient, Project: project}
	log.Printf("Gemini: %s / Maps: %s", ai.mode(), maps.mode())
	return &App{
		Verify: func(ctx context.Context, token string) (string, error) {
			decoded, err := auth.VerifyIDToken(ctx, token)
			if err != nil {
				return "", err
			}
			return decoded.UID, nil
		},
		Store: &FirestoreStore{Client: db},
		Maps:  maps,
		AI:    ai,
	}, db.Close, nil
}
