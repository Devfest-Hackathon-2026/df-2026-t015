package replans

import (
	"net/http"

	"github.com/create-alt/gen-TLE/server/internal/service"
)

func Accept(app *service.App) http.HandlerFunc {
	return service.Handle(func(w http.ResponseWriter, r *http.Request) error {
		version, err := service.Version(r)
		if err != nil {
			return err
		}
		var input struct {
			OptionID string `json:"optionId"`
		}
		if err := service.Decode(w, r, &input); err != nil {
			return err
		}
		if !service.ValidID(input.OptionID) || !service.ValidID(r.PathValue("id")) || !service.ValidID(r.PathValue("replanId")) {
			return service.Invalid("旅程・案・optionId が不正です")
		}
		value, err := app.Store.Accept(r.Context(), service.UID(r), r.PathValue("id"), r.PathValue("replanId"), input.OptionID, version)
		if err != nil {
			return err
		}
		service.ReplyItinerary(w, 200, value)
		return nil
	})
}
