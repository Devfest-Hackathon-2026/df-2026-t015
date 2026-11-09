package service

import (
	"context"
	"encoding/json"
	"errors"
	"io"
	"math"
	"mime"
	"net/http"
	"net/url"
	"strconv"
	"strings"
	"time"
	"unicode/utf8"
)

type Error struct {
	Status  int            `json:"-"`
	Code    string         `json:"code"`
	Message string         `json:"message"`
	Details map[string]any `json:"details"`
}

func Handle(fn func(http.ResponseWriter, *http.Request) error) http.HandlerFunc {
	return func(w http.ResponseWriter, r *http.Request) {
		if err := fn(w, r); err != nil {
			WriteError(w, err)
		}
	}
}

func (e *Error) Error() string { return e.Code + ": " + e.Message }

func Fail(status int, code, message string) *Error {
	return &Error{Status: status, Code: code, Message: message, Details: map[string]any{}}
}

func Invalid(message string) *Error { return Fail(400, "INVALID_ARGUMENT", message) }
func NotFound() *Error              { return Fail(404, "NOT_FOUND", "対象が見つかりません") }
func Conflict() *Error {
	return Fail(409, "VERSION_CONFLICT", "旅程がほかの操作で更新されています")
}
func Expired() *Error {
	return Fail(410, "REPLAN_EXPIRED", "組み直し案の有効期限が切れています")
}
func Upstream() *Error {
	return Fail(502, "UPSTREAM_ERROR", "外部サービスの処理に失敗しました")
}

func APIError(err error) *Error {
	var apiError *Error
	if errors.As(err, &apiError) {
		return apiError
	}
	return Upstream()
}

func JSON(w http.ResponseWriter, status int, value any) {
	w.Header().Set("Content-Type", "application/json; charset=utf-8")
	w.WriteHeader(status)
	_ = json.NewEncoder(w).Encode(value)
}

func WriteError(w http.ResponseWriter, err error) {
	e := APIError(err)
	if e.Status == 429 {
		w.Header().Set("Retry-After", "60")
	}
	JSON(w, e.Status, map[string]any{"error": e})
}

func Decode(w http.ResponseWriter, r *http.Request, value any) error {
	mediaType, _, err := mime.ParseMediaType(r.Header.Get("Content-Type"))
	if err != nil || mediaType != "application/json" {
		return Invalid("Content-Type は application/json を指定してください")
	}
	body, err := io.ReadAll(http.MaxBytesReader(w, r.Body, 64<<10))
	if err != nil || !utf8.Valid(body) || strings.TrimSpace(string(body)) == "null" {
		return Invalid("JSON が不正です")
	}
	decoder := json.NewDecoder(strings.NewReader(string(body)))
	decoder.DisallowUnknownFields()
	if err := decoder.Decode(value); err != nil {
		return Invalid("JSON の形式やフィールドが不正です")
	}
	if decoder.Decode(new(any)) != io.EOF {
		return Invalid("JSON は1つだけ送信してください")
	}
	return nil
}

func Text(value string, min, max int) bool {
	length := utf8.RuneCountInString(value)
	return utf8.ValidString(value) && strings.TrimSpace(value) != "" && length >= min && length <= max
}

func ValidID(value string) bool {
	return Text(value, 1, 200) && value == strings.TrimSpace(value) && !strings.ContainsAny(value, "/\\\x00\r\n") && value != "." && value != ".."
}

func Coordinates(r *http.Request) (*Point, error) {
	q, err := Query(r, "q", "lat", "lng")
	if err != nil {
		return nil, err
	}
	if !q.Has("lat") && !q.Has("lng") {
		return nil, nil
	}
	lat, err1 := strconv.ParseFloat(q.Get("lat"), 64)
	lng, err2 := strconv.ParseFloat(q.Get("lng"), 64)
	point := Point{Lat: lat, Lng: lng}
	if err1 != nil || err2 != nil || !ValidPoint(point) {
		return nil, Invalid("lat / lng を正しい緯度・経度で指定してください")
	}
	return &point, nil
}

func Query(r *http.Request, allowed ...string) (url.Values, error) {
	values, err := url.ParseQuery(r.URL.RawQuery)
	if err != nil {
		return nil, Invalid("クエリの形式が不正です")
	}
	keys := map[string]bool{}
	for _, key := range allowed {
		keys[key] = true
	}
	for key, entries := range values {
		if !keys[key] || len(entries) != 1 {
			return nil, Invalid("クエリに未定義または重複した項目があります")
		}
	}
	return values, nil
}

func ValidPoint(p Point) bool {
	return !math.IsNaN(p.Lat) && !math.IsNaN(p.Lng) && !math.IsInf(p.Lat, 0) && !math.IsInf(p.Lng, 0) && p.Lat >= -90 && p.Lat <= 90 && p.Lng >= -180 && p.Lng <= 180
}

func Version(r *http.Request) (int, error) {
	value := r.Header.Get("If-Match")
	if strings.HasPrefix(value, `"`) && strings.HasSuffix(value, `"`) && len(value) > 2 {
		value = value[1 : len(value)-1]
	}
	version, err := strconv.Atoi(value)
	if err != nil || version < 1 {
		return 0, Invalid("If-Match に正しい version を指定してください")
	}
	return version, nil
}

func ReplyItinerary(w http.ResponseWriter, status int, itinerary Itinerary) {
	w.Header().Set("ETag", `"`+strconv.Itoa(itinerary.Version)+`"`)
	JSON(w, status, itinerary)
}

type userKey struct{}

func UID(r *http.Request) string { uid, _ := r.Context().Value(userKey{}).(string); return uid }

func (a *App) Auth(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		parts := strings.Fields(r.Header.Get("Authorization"))
		if len(parts) != 2 || !strings.EqualFold(parts[0], "Bearer") || a.Verify == nil {
			WriteError(w, Fail(401, "UNAUTHENTICATED", "Firebase ID token が必要です"))
			return
		}
		ctx, cancel := context.WithTimeout(r.Context(), 60*time.Second)
		defer cancel()
		uid, err := a.Verify(ctx, parts[1])
		if err != nil || uid == "" {
			WriteError(w, Fail(401, "UNAUTHENTICATED", "Firebase ID token が無効です"))
			return
		}
		if err := a.Store.Allow(ctx, uid); err != nil {
			WriteError(w, err)
			return
		}
		next.ServeHTTP(w, r.WithContext(context.WithValue(ctx, userKey{}, uid)))
	})
}

func (a *App) Owned(r *http.Request) (Itinerary, error) {
	if !ValidID(r.PathValue("id")) {
		return Itinerary{}, Invalid("旅程IDが不正です")
	}
	return a.Store.Get(r.Context(), UID(r), r.PathValue("id"))
}

func (a *App) OwnedReplan(r *http.Request) (Replan, error) {
	if !ValidID(r.PathValue("id")) || !ValidID(r.PathValue("replanId")) {
		return Replan{}, Invalid("旅程・案のIDが不正です")
	}
	return a.Store.GetReplan(r.Context(), UID(r), r.PathValue("id"), r.PathValue("replanId"))
}
