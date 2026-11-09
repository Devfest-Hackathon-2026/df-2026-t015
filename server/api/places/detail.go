package places

import (
	"net/http"
	"time"

	"github.com/create-alt/gen-TLE/server/internal/service"
)

// Detail は GET /places/:placeId（F-10）。地図で選んだ施設の詳しい情報と、date の日の営業時間を返す。
// date を省略すると今日（日本時間）の営業時間を返す。
func Detail(app *service.App) http.HandlerFunc {
	return service.Handle(func(w http.ResponseWriter, r *http.Request) error {
		id := r.PathValue("placeId")
		if !service.ValidID(id) {
			return service.Invalid("placeId が不正です")
		}
		date := time.Now().In(service.JST)
		if value := r.URL.Query().Get("date"); r.URL.Query().Has("date") {
			parsed, err := time.ParseInLocation("2006-01-02", value, service.JST)
			if err != nil {
				return service.Invalid("date は YYYY-MM-DD で指定してください")
			}
			date = parsed
		}
		detail, err := app.Maps.Detail(r.Context(), id, date)
		if err != nil {
			return err
		}
		service.JSON(w, 200, detail)
		return nil
	})
}
