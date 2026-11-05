package itineraries

import (
	"net/http"

	"github.com/create-alt/gen-TLE/server/internal/service"
)

func Create(app *service.App) http.HandlerFunc {
	return service.Handle(func(w http.ResponseWriter, r *http.Request) error {
		var input service.PlanInput
		if err := service.Decode(w, r, &input); err != nil {
			return err
		}
		value, err := app.Plan(r.Context(), input)
		if err != nil {
			return err
		}
		if err := app.Store.Create(r.Context(), service.UID(r), &value); err != nil {
			return err
		}
		service.ReplyItinerary(w, 201, value)
		return nil
	})
}
