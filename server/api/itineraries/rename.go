package itineraries

import (
	"net/http"

	"github.com/create-alt/gen-TLE/server/internal/service"
)

// Rename は PATCH /itineraries/:id（F-09）。旅程の名前を変える。
// 旅行日・出発・終わりの変更は時刻の計算が要るため PUT /itineraries/:id/places を使う。
func Rename(app *service.App) http.HandlerFunc {
	return service.Handle(func(w http.ResponseWriter, r *http.Request) error {
		version, err := service.Version(r)
		if err != nil {
			return err
		}
		var input struct {
			Title string `json:"title"`
		}
		if err := service.Decode(w, r, &input); err != nil {
			return err
		}
		if err := service.ValidateTitle(input.Title); err != nil {
			return err
		}
		value, err := app.Owned(r)
		if err != nil {
			return err
		}
		if value.Version != version {
			return service.Conflict()
		}
		value.Title = input.Title
		if err := app.Store.Update(r.Context(), service.UID(r), value.ID, version, &value); err != nil {
			return err
		}
		service.ReplyItinerary(w, 200, value)
		return nil
	})
}
