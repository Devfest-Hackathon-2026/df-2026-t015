package itineraries

import (
	"net/http"

	"github.com/create-alt/gen-TLE/server/internal/service"
)

func AddItem(app *service.App) http.HandlerFunc {
	return service.Handle(func(w http.ResponseWriter, r *http.Request) error {
		version, err := service.Version(r)
		if err != nil {
			return err
		}
		var input service.AddInput
		if err := service.Decode(w, r, &input); err != nil {
			return err
		}
		if err := service.ValidateVisits([]service.Visit{{PlaceID: input.PlaceID, Priority: input.Priority, StayMin: input.StayMin}}); err != nil {
			return err
		}
		old, err := app.Owned(r)
		if err != nil {
			return err
		}
		if old.Version != version {
			return service.Conflict()
		}
		value, err := app.Add(r.Context(), old, input)
		if err != nil {
			return err
		}
		if err := app.Store.Update(r.Context(), service.UID(r), old.ID, version, &value); err != nil {
			return err
		}
		service.ReplyItinerary(w, 200, value)
		return nil
	})
}
