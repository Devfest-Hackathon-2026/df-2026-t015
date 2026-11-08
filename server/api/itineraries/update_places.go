package itineraries

import (
	"net/http"

	"github.com/create-alt/gen-TLE/server/internal/service"
)

// UpdatePlaces は PUT /itineraries/:id/places（F-01、F-02、F-09、F-10）。
// 行き先・優先度・出発と終わり・旅行日を変えて旅程を作り直す。date・start・end は省略すると今の値のまま。
func UpdatePlaces(app *service.App) http.HandlerFunc {
	return service.Handle(func(w http.ResponseWriter, r *http.Request) error {
		version, err := service.Version(r)
		if err != nil {
			return err
		}
		var input service.EditInput
		if err := service.Decode(w, r, &input); err != nil {
			return err
		}
		// 行き先の詳しい確認は Edit で行う（完了済み・滞在中の予定は滞在時間の範囲を確認しないため）。
		if len(input.Places) < 1 || len(input.Places) > 10 {
			return service.Invalid("places は1〜10件で指定してください")
		}
		old, err := app.Owned(r)
		if err != nil {
			return err
		}
		if old.Version != version {
			return service.Conflict()
		}
		value, err := app.Edit(r.Context(), old, input)
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
