package places

import (
	"net/http"
	"strconv"

	"github.com/create-alt/gen-TLE/server/internal/service"
)

// Nearby は GET /places/nearby（F-10）。地図に表示している範囲の施設を最大20件返す。
// 出発地・終わる場所・行き先を地図から選ぶ画面で使う。
func Nearby(app *service.App) http.HandlerFunc {
	return service.Handle(func(w http.ResponseWriter, r *http.Request) error {
		query := r.URL.Query()
		lat, err1 := strconv.ParseFloat(query.Get("lat"), 64)
		lng, err2 := strconv.ParseFloat(query.Get("lng"), 64)
		center := service.Point{Lat: lat, Lng: lng}
		if err1 != nil || err2 != nil || !service.ValidPoint(center) {
			return service.Invalid("lat / lng を正しい緯度・経度で指定してください")
		}
		radius := 1000
		if query.Has("radius") {
			value, err := strconv.Atoi(query.Get("radius"))
			if err != nil || value < 100 || value > 5000 {
				return service.Invalid("radius は100〜5000で指定してください")
			}
			radius = value
		}
		q := query.Get("q")
		if query.Has("q") && !service.Text(q, 1, 100) {
			return service.Invalid("q は1〜100文字で指定してください")
		}
		places, err := app.Maps.Nearby(r.Context(), center, radius, q)
		if err != nil {
			return err
		}
		service.JSON(w, 200, map[string]any{"places": places})
		return nil
	})
}
