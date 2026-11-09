package main

import (
	"context"
	"errors"
	"io/fs"
	"log"
	"net/http"
	"os"
	"os/signal"
	"path/filepath"
	"syscall"
	"time"

	"github.com/create-alt/gen-TLE/server/api"
	"github.com/create-alt/gen-TLE/server/internal/service"
	"github.com/joho/godotenv"
)

func main() {
	loadDotEnv()
	ctx, stop := signal.NotifyContext(context.Background(), os.Interrupt, syscall.SIGTERM)
	defer stop()
	startup, cancel := context.WithTimeout(ctx, 15*time.Second)
	app, closeDB, err := service.Connect(startup)
	cancel()
	if err != nil {
		log.Fatal(err)
	}
	defer closeDB()
	port := service.Port()
	server := &http.Server{Addr: ":" + port, Handler: api.Public(api.New(app), api.PublicOptionsFromEnv()), ReadHeaderTimeout: 5 * time.Second, ReadTimeout: 10 * time.Second, WriteTimeout: 70 * time.Second, IdleTimeout: 60 * time.Second, MaxHeaderBytes: 16 << 10}
	done := make(chan struct{})
	go func() {
		defer close(done)
		<-ctx.Done()
		shutdown, cancel := context.WithTimeout(context.Background(), 10*time.Second)
		defer cancel()
		if err := server.Shutdown(shutdown); err != nil {
			log.Printf("shutdown: %v", err)
		}
	}()
	log.Printf("API listening on :%s", port)
	if err := server.ListenAndServe(); err != nil && !errors.Is(err, http.ErrServerClosed) {
		log.Fatal(err)
	}
	<-done
}

// loadDotEnv はカレントディレクトリから go.mod のあるディレクトリまで遡って
// 最初に見つかった .env を読み込む。既に設定済みの環境変数は上書きしない。
// .env が見つからなければ何もしない（Cloud Run など）。
func loadDotEnv() {
	dir, err := os.Getwd()
	if err != nil {
		return
	}
	for {
		path := filepath.Join(dir, ".env")
		if err := godotenv.Load(path); err == nil {
			log.Printf("loaded %s", path)
			return
		} else if !errors.Is(err, fs.ErrNotExist) {
			log.Fatalf(".env の読み込みに失敗しました (%s): %v", path, err)
		}
		if _, err := os.Stat(filepath.Join(dir, "go.mod")); err == nil {
			return
		}
		parent := filepath.Dir(dir)
		if parent == dir {
			return
		}
		dir = parent
	}
}
