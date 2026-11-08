package itineraries

import (
	"net/http"

	"github.com/create-alt/gen-TLE/server/internal/service"
)

// Delete は DELETE /itineraries/:id（F-09）。旅程と、その旅程の組み直し案を削除して204を返す。
func Delete(app *service.App) http.HandlerFunc {
	return service.Handle(func(w http.ResponseWriter, r *http.Request) error {
		version, err := service.Version(r)
		if err != nil {
			return err
		}
		id := r.PathValue("id")
		if !service.ValidID(id) {
			return service.Invalid("旅程IDが不正です")
		}
		if err := app.Store.Delete(r.Context(), service.UID(r), id, version); err != nil {
			return err
		}
		w.WriteHeader(http.StatusNoContent)
		return nil
	})
}
