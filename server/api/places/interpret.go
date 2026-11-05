package places

import (
	"encoding/json"
	"github.com/create-alt/gen-TLE/server/internal/service"
	"net/http"
)

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
		var output struct {
			Queries []struct {
				Query  string `json:"query"`
				Reason string `json:"reason"`
			} `json:"queries"`
		}
		schema := service.ObjectSchema(map[string]any{
			"queries": map[string]any{
				"type": "array", "minItems": 1, "maxItems": 5,
				"items": service.ObjectSchema(map[string]any{
					"query":  map[string]string{"type": "string"},
					"reason": map[string]string{"type": "string"},
				}),
			},
		})
		data, _ := json.Marshal(input.Text)
		if err := app.AI.Generate(r.Context(), "次の旅行の希望をPlacesで探せる検索語と選択理由にしてください。検索語は最大5件。\n"+string(data), schema, &output); err != nil {
			return err
		}
		if len(output.Queries) < 1 || len(output.Queries) > 5 {
			return service.Upstream()
		}
		type candidate struct {
			Place  service.Place `json:"place"`
			Reason string        `json:"reason"`
		}
		candidates := []candidate{}
		seen := map[string]bool{}
		for _, query := range output.Queries {
			if !service.Text(query.Query, 1, 200) || !service.Text(query.Reason, 1, 500) {
				return service.Upstream()
			}
			places, err := app.Maps.Search(r.Context(), query.Query, near)
			if err != nil {
				return err
			}
			for _, place := range places {
				if !seen[place.PlaceID] {
					seen[place.PlaceID] = true
					candidates = append(candidates, candidate{Place: place, Reason: query.Reason})
					break
				}
			}
		}
		service.JSON(w, 200, map[string]any{"candidates": candidates})
		return nil
	})
}
