package itineraries

import (
	"net/http"
	"time"

	"github.com/create-alt/gen-TLE/server/internal/service"
)

// Suggestions は GET /itineraries/:id/suggestions（F-07）。
// 前後の移動時間を除いても十分に過ごせる近くの施設（suggestions）と、施設を決めない過ごし方（ideas）を返す。
func Suggestions(app *service.App) http.HandlerFunc {
	return service.Handle(func(w http.ResponseWriter, r *http.Request) error {
		from, err := time.Parse(time.RFC3339, r.URL.Query().Get("from"))
		if err != nil {
			return service.Invalid("from が不正です")
		}
		to, err := time.Parse(time.RFC3339, r.URL.Query().Get("to"))
		if err != nil || !to.After(from) {
			return service.Invalid("to は from より後の日時を指定してください")
		}
		value, err := app.Owned(r)
		if err != nil {
			return err
		}
		result, err := app.Suggest(r.Context(), value, from.In(service.JST), to.In(service.JST), r.URL.Query().Get("afterItemId"))
		if err != nil {
			return err
		}
		service.JSON(w, 200, result)
		return nil
	})
}
