package itineraries

import (
	"net/http"

	"github.com/create-alt/gen-TLE/server/internal/service"
)

// Copy は POST /itineraries/:id/copy（F-11）。旅程を別の日にコピーし、新しい旅程を201で返す。
func Copy(app *service.App) http.HandlerFunc {
	return service.Handle(func(w http.ResponseWriter, r *http.Request) error {
		var input struct {
			Date  string  `json:"date"`
			Title *string `json:"title"`
		}
		if err := service.Decode(w, r, &input); err != nil {
			return err
		}
		if input.Date == "" {
			return service.Invalid("date は必須です")
		}
		title := ""
		if input.Title != nil {
			if err := service.ValidateTitle(*input.Title); err != nil {
				return err
			}
			title = *input.Title
		}
		old, err := app.Owned(r)
		if err != nil {
			return err
		}
		count, err := app.Store.Count(r.Context(), service.UID(r))
		if err != nil {
			return err
		}
		if count >= service.MaxItineraries {
			return service.ItineraryLimit()
		}
		value, err := app.Copy(r.Context(), old, input.Date, title)
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
