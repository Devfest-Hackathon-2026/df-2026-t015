package api

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"net/url"
	"os"
	"strconv"
	"testing"
	"time"

	"github.com/create-alt/gen-TLE/server/internal/service"
	"github.com/joho/godotenv"
)

// TestLiveAPI は本物の Firebase Auth・Firestore・Google Maps・Gemini に接続して、
// 主なAPIを順番に呼ぶ。外部サービスの料金がかかるため、GENTLE_LIVE_TEST=1 のときだけ動く。
//
//	GENTLE_LIVE_TEST=1 go test ./api -run TestLiveAPI -v
//
// server/.env（または環境変数）に通常の設定に加えて FIREBASE_WEB_API_KEY が必要。
// 匿名ユーザーを作ってIDトークンを取得し、作った旅程と匿名ユーザーは最後に削除する。
func TestLiveAPI(t *testing.T) {
	if os.Getenv("GENTLE_LIVE_TEST") != "1" {
		t.Skip("GENTLE_LIVE_TEST=1 のときだけ実行します（本物の外部サービスに接続します）")
	}
	_ = godotenv.Load("../.env")
	webKey := os.Getenv("FIREBASE_WEB_API_KEY")
	if webKey == "" {
		t.Fatal("FIREBASE_WEB_API_KEY を設定してください（Firebase コンソール → プロジェクトの設定 → ウェブ API キー）")
	}

	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Minute)
	defer cancel()
	app, closeDB, err := service.Connect(ctx)
	if err != nil {
		t.Fatal(err)
	}
	t.Cleanup(func() { _ = closeDB() })
	server := httptest.NewServer(New(app))
	t.Cleanup(server.Close)

	token := anonymousToken(t, webKey)

	type response struct {
		status int
		body   []byte
		header http.Header
	}
	send := func(method, path, auth string, ifMatch string, input any) response {
		t.Helper()
		var body io.Reader
		if input != nil {
			data, err := json.Marshal(input)
			if err != nil {
				t.Fatal(err)
			}
			body = bytes.NewReader(data)
		}
		r, err := http.NewRequestWithContext(ctx, method, server.URL+path, body)
		if err != nil {
			t.Fatal(err)
		}
		r.Header.Set("Content-Type", "application/json")
		if auth != "" {
			r.Header.Set("Authorization", "Bearer "+auth)
		}
		if ifMatch != "" {
			r.Header.Set("If-Match", ifMatch)
		}
		w, err := http.DefaultClient.Do(r)
		if err != nil {
			t.Fatalf("%s %s: %v", method, path, err)
		}
		defer w.Body.Close()
		data, _ := io.ReadAll(w.Body)
		return response{w.StatusCode, data, w.Header}
	}
	// call は認証つきで呼び、期待したステータスでなければテストを止める。
	call := func(method, path, ifMatch string, input any, want int, output any) response {
		t.Helper()
		start := time.Now()
		res := send(method, path, token, ifMatch, input)
		t.Logf("%s %s → %d (%s)", method, path, res.status, time.Since(start).Round(time.Millisecond))
		if res.status != want {
			t.Fatalf("%s %s: want %d, got %d: %s", method, path, want, res.status, res.body)
		}
		if output != nil {
			if err := json.Unmarshal(res.body, output); err != nil {
				t.Fatalf("%s %s: %v: %s", method, path, err, res.body)
			}
		}
		return res
	}

	// 旅行日は1週間後（日本時間）。営業時間の取得・公共交通の検索の範囲内にする。
	jst := time.FixedZone("JST", 9*60*60)
	date := time.Now().In(jst).AddDate(0, 0, 7).Format("2006-01-02")

	t.Run("healthz", func(t *testing.T) {
		if res := send("GET", "/healthz", "", "", nil); res.status != 200 {
			t.Fatalf("healthz: %d %s", res.status, res.body)
		}
	})
	t.Run("認証なしは401", func(t *testing.T) {
		if res := send("GET", "/places/autocomplete?q=a", "", "", nil); res.status != 401 {
			t.Fatalf("want 401, got %d %s", res.status, res.body)
		}
	})

	// Maps: Places Autocomplete → 出発地・終わる場所に使う
	var autocomplete struct {
		Candidates []service.Place `json:"candidates"`
	}
	call("GET", "/places/autocomplete?q="+url.QueryEscape("東京駅"), "", nil, 200, &autocomplete)
	if len(autocomplete.Candidates) == 0 {
		t.Fatal("autocomplete: 候補が0件です")
	}
	station := autocomplete.Candidates[0].PlaceID

	// Maps: Place Details / Nearby Search
	var detail service.PlaceDetail
	call("GET", "/places/"+url.PathEscape(station)+"?date="+date, "", nil, 200, &detail)
	var nearby struct {
		Places []service.NearbyPlace `json:"places"`
	}
	call("GET", "/places/nearby?lat=35.6812&lng=139.7671&radius=500", "", nil, 200, &nearby)
	if len(nearby.Places) == 0 {
		t.Error("nearby: 候補が0件です")
	}

	// Gemini + Maps: 希望文から施設を探す
	var interpreted struct {
		Candidates []service.Interpreted `json:"candidates"`
	}
	call("POST", "/places/interpret", "", map[string]string{"text": "浅草でお寺を見て、上野の公園を散歩したい"}, 200, &interpreted)
	if len(interpreted.Candidates) == 0 {
		t.Fatal("interpret: 候補が0件です")
	}
	places := []map[string]any{}
	for i, candidate := range interpreted.Candidates {
		if i == 2 {
			break
		}
		places = append(places, map[string]any{"placeId": candidate.Place.PlaceID, "priority": "want", "stayMin": 60})
	}

	// Gemini + Maps + Firestore: 旅程を作る
	var trip service.Itinerary
	call("POST", "/itineraries", "", map[string]any{
		"title":  "ライブテスト",
		"date":   date,
		"start":  map[string]any{"placeId": station, "departAt": "10:00"},
		"end":    map[string]any{"placeId": station, "arriveBy": "18:00"},
		"places": places,
	}, 201, &trip)
	if trip.ID == "" || len(trip.Legs) == 0 {
		t.Fatalf("旅程が不完全です: %+v", trip)
	}
	t.Logf("旅程 %s: 予定 %d 件、外した行き先 %d 件", trip.ID, len(trip.Items), len(trip.Dropped))
	deleted := false
	t.Cleanup(func() {
		if !deleted {
			send("DELETE", "/itineraries/"+trip.ID, token, strconv.Itoa(trip.Version), nil)
		}
	})

	// Firestore: 取得・一覧・名前の変更・削除
	call("GET", "/itineraries/"+trip.ID, "", nil, 200, &trip)
	t.Run("一覧", func(t *testing.T) {
		// 複合インデックス（firestore.indexes.json）が無いと失敗する。
		var page service.ItineraryPage
		res := send("GET", "/me/itineraries?limit=5", token, "", nil)
		if res.status != 200 {
			t.Fatalf("want 200, got %d: %s（firestore.indexes.json の複合インデックスを作成してください）", res.status, res.body)
		}
		if err := json.Unmarshal(res.body, &page); err != nil {
			t.Fatal(err)
		}
		found := false
		for _, entry := range page.Itineraries {
			found = found || entry.ID == trip.ID
		}
		if !found {
			t.Errorf("作った旅程 %s が一覧にありません: %s", trip.ID, res.body)
		}
	})
	call("PATCH", "/itineraries/"+trip.ID, strconv.Itoa(trip.Version), map[string]string{"title": "ライブテスト（変更後）"}, 200, &trip)
	if trip.Title != "ライブテスト（変更後）" {
		t.Errorf("名前が変わっていません: %q", trip.Title)
	}
	call("DELETE", "/itineraries/"+trip.ID, strconv.Itoa(trip.Version), nil, 204, nil)
	deleted = true
	call("GET", "/itineraries/"+trip.ID, "", nil, 404, nil)
}

// anonymousToken は Firebase Auth の匿名ユーザーを作り、IDトークンを返す。
// 作ったユーザーはテストの最後に削除する。
func anonymousToken(t *testing.T, webKey string) string {
	t.Helper()
	post := func(method string, input any, output any) error {
		data, _ := json.Marshal(input)
		res, err := http.Post("https://identitytoolkit.googleapis.com/v1/accounts:"+method+"?key="+url.QueryEscape(webKey), "application/json", bytes.NewReader(data))
		if err != nil {
			return err
		}
		defer res.Body.Close()
		body, _ := io.ReadAll(res.Body)
		if res.StatusCode != 200 {
			return fmt.Errorf("accounts:%s: HTTP %d: %s", method, res.StatusCode, body)
		}
		if output != nil {
			return json.Unmarshal(body, output)
		}
		return nil
	}
	var signUp struct {
		IDToken string `json:"idToken"`
	}
	if err := post("signUp", map[string]bool{"returnSecureToken": true}, &signUp); err != nil {
		t.Fatalf("匿名ログインに失敗しました（Authentication で「匿名」を有効にしてください）: %v", err)
	}
	t.Cleanup(func() {
		if err := post("delete", map[string]string{"idToken": signUp.IDToken}, nil); err != nil {
			t.Logf("匿名ユーザーの削除に失敗しました: %v", err)
		}
	})
	return signUp.IDToken
}
