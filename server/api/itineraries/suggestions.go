package itineraries

import (
	"net/http"
	"time"

	"github.com/create-alt/gen-TLE/server/internal/service"
)

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
		suggestions, err := app.Suggest(r.Context(), value, from.In(service.JST), to.In(service.JST), r.URL.Query().Get("afterItemId"))
		if err != nil {
			return err
		}
		service.JSON(w, 200, map[string]any{"suggestions": suggestions})
		return nil
	})
}
