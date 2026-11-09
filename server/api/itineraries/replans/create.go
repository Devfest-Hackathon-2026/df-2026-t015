package replans

import (
	"net/http"

	"github.com/create-alt/gen-TLE/server/internal/service"
)

func Create(app *service.App) http.HandlerFunc {
	return service.Handle(func(w http.ResponseWriter, r *http.Request) error {
		var input service.ReplanInput
		if err := service.Decode(w, r, &input); err != nil {
			return err
		}
		if err := service.ValidateReplan(input); err != nil {
			return err
		}
		trip, err := app.Owned(r)
		if err != nil {
			return err
		}
		value, err := app.Replan(r.Context(), trip, input)
		if err != nil {
			return err
		}
		if value.NeedsChange {
			if err := app.Store.SaveReplan(r.Context(), service.UID(r), &value); err != nil {
				return err
			}
			service.JSON(w, 200, value)
		} else {
			service.JSON(w, 200, map[string]any{"needsChange": false, "warnings": value.Warnings, "options": value.Options})
		}
		return nil
	})
}
