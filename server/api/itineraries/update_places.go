package itineraries

import (
	"net/http"

	"github.com/create-alt/gen-TLE/server/internal/service"
)

func UpdatePlaces(app *service.App) http.HandlerFunc {
	return service.Handle(func(w http.ResponseWriter, r *http.Request) error {
		version, err := service.Version(r)
		if err != nil {
			return err
		}
		var input struct {
			EndBy  string          `json:"endBy"`
			Places []service.Visit `json:"places"`
		}
		if err := service.Decode(w, r, &input); err != nil {
			return err
		}
		if len(input.Places) < 1 || len(input.Places) > 10 {
			return service.Invalid("places は1〜10件で指定してください")
		}
		old, err := app.Owned(r)
		if err != nil {
			return err
		}
		if old.Version != version {
			return service.Conflict()
		}
		value, err := app.Edit(r.Context(), old, input.Places, input.EndBy)
		if err != nil {
			return err
		}
		if err := app.Store.Update(r.Context(), service.UID(r), old.ID, version, &value); err != nil {
			return err
		}
		service.ReplyItinerary(w, 200, value)
		return nil
	})
}
