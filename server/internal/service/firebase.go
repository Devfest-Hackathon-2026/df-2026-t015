package service

import (
	"context"
	"fmt"
	"net/http"
	"os"
	"time"

	firebase "firebase.google.com/go/v4"
)

func Connect(ctx context.Context) (*App, func() error, error) {
	for _, key := range []string{"FIREBASE_PROJECT_ID", "GOOGLE_MAPS_API_KEY", "GEMINI_API_KEY", "GEMINI_MODEL"} {
		if os.Getenv(key) == "" {
			return nil, nil, fmt.Errorf("%s を設定してください", key)
		}
	}
	app, err := firebase.NewApp(ctx, &firebase.Config{ProjectID: os.Getenv("FIREBASE_PROJECT_ID")})
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
	return &App{
		Verify: func(ctx context.Context, token string) (string, error) {
			decoded, err := auth.VerifyIDToken(ctx, token)
			if err != nil {
				return "", err
			}
			return decoded.UID, nil
		},
		Store: &FirestoreStore{Client: db},
		Maps:  &Maps{Key: os.Getenv("GOOGLE_MAPS_API_KEY"), HTTP: client},
		AI:    &Gemini{Key: os.Getenv("GEMINI_API_KEY"), Model: os.Getenv("GEMINI_MODEL"), HTTP: client},
	}, db.Close, nil
}
