package places

import (
	"net/http"

	"github.com/create-alt/gen-TLE/server/internal/service"
)

// Interpret は POST /places/interpret（F-01）。自由文を Gemini で解釈し、Places API で実在する施設に絞って返す。
func Interpret(app *service.App) http.HandlerFunc {
	return service.Handle(func(w http.ResponseWriter, r *http.Request) error {
		var input struct {
			Text string `json:"text"`
			Near *struct {
				Lat     *float64 `json:"lat"`
				Lng     *float64 `json:"lng"`
				PlaceID string   `json:"placeId"`
			} `json:"near"`
		}
		if err := service.Decode(w, r, &input); err != nil {
			return err
		}
		if !service.Text(input.Text, 1, 200) {
			return service.Invalid("text は1〜200文字で指定してください")
		}
		var near *service.Point
		if input.Near != nil {
			n := input.Near
			switch {
			case n.PlaceID != "" && n.Lat == nil && n.Lng == nil:
				if !service.ValidID(n.PlaceID) {
					return service.Invalid("near.placeId が不正です")
				}
				place, err := app.Maps.Details(r.Context(), n.PlaceID)
				if err != nil {
					return err
				}
				near = &place.Location
			case n.PlaceID == "" && n.Lat != nil && n.Lng != nil:
				near = &service.Point{Lat: *n.Lat, Lng: *n.Lng}
				if !service.ValidPoint(*near) {
					return service.Invalid("near の緯度・経度が不正です")
				}
			default:
				return service.Invalid("near は lat / lng または placeId の一方を指定してください")
			}
		}
		candidates, err := app.Interpret(r.Context(), input.Text, near)
		if err != nil {
			return err
		}
		service.JSON(w, 200, map[string]any{"candidates": candidates})
		return nil
	})
}
