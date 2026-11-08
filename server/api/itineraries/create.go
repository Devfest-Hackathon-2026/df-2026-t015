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
		if err := service.ValidatePlan(input); err != nil {
			return err
		}
		// Maps と Gemini を呼ぶ前に上限を確かめる。保存時にもトランザクション内で確認する。
		count, err := app.Store.Count(r.Context(), service.UID(r))
		if err != nil {
			return err
		}
		if count >= service.MaxItineraries {
			return service.ItineraryLimit()
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
