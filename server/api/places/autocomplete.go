package places

import (
	"net/http"

	"github.com/create-alt/gen-TLE/server/internal/service"
)

func Autocomplete(app *service.App) http.HandlerFunc {
	return service.Handle(func(w http.ResponseWriter, r *http.Request) error {
		query := r.URL.Query().Get("q")
		if !service.Text(query, 1, 100) {
			return service.Invalid("q は1〜100文字で指定してください")
		}
		near, err := service.Coordinates(r)
		if err != nil {
			return err
		}
		places, err := app.Maps.Autocomplete(r.Context(), query, near)
		if err != nil {
			return err
		}
		type candidate struct {
			PlaceID string `json:"placeId"`
			Name    string `json:"name"`
			Address string `json:"address"`
		}
		candidates := []candidate{}
		for _, place := range places {
			candidates = append(candidates, candidate{PlaceID: place.PlaceID, Name: place.Name, Address: place.Address})
		}
		service.JSON(w, 200, map[string]any{"candidates": candidates})
		return nil
	})
}
