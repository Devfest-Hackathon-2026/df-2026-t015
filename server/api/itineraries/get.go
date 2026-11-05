package itineraries

import (
	"net/http"

	"github.com/create-alt/gen-TLE/server/internal/service"
)

func Get(app *service.App) http.HandlerFunc {
	return service.Handle(func(w http.ResponseWriter, r *http.Request) error {
		value, err := app.Owned(r)
		if err != nil {
			return err
		}
		service.ReplyItinerary(w, 200, value)
		return nil
	})
}
