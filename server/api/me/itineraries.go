package me

import (
	"net/http"

	"github.com/create-alt/gen-TLE/server/internal/service"
)

func Itineraries(app *service.App) http.HandlerFunc {
	return service.Handle(func(w http.ResponseWriter, r *http.Request) error {
		values, err := app.Store.List(r.Context(), service.UID(r))
		if err != nil {
			return err
		}
		service.JSON(w, 200, map[string]any{"itineraries": values})
		return nil
	})
}
