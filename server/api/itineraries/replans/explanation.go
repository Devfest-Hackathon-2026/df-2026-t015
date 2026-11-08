package replans

import (
	"context"
	"net/http"
	"time"

	"github.com/create-alt/gen-TLE/server/internal/service"
)

// Explanation は GET /itineraries/:id/replans/:replanId/explanation（F-05）。
// 組み直し案の変更点からサーバーが事実を取り出し、Gemini が要約（text）と変更ごとの理由（reasons）にする。
// 初回の取得で生成して保存し、生成中は pending、失敗したら failed を返す（案の確定はできる）。
func Explanation(app *service.App) http.HandlerFunc {
	return service.Handle(func(w http.ResponseWriter, r *http.Request) error {
		optionID := r.URL.Query().Get("optionId")
		if !service.ValidID(optionID) {
			return service.Invalid("optionId が必要です")
		}
		value, err := app.OwnedReplan(r)
		if err != nil {
			return err
		}
		var option *service.Option
		for i := range value.Options {
			if value.Options[i].OptionID == optionID {
				option = &value.Options[i]
				break
			}
		}
		if option == nil {
			return service.Invalid("optionId が不正です")
		}
		result, claimed, err := app.Store.ClaimExplanation(r.Context(), service.UID(r), r.PathValue("id"), r.PathValue("replanId"), optionID)
		if err != nil {
			return err
		}
		if claimed {
			final, _ := app.Explain(r.Context(), value, *option)
			// キャンセル後も処理権を解放し、ほかの取得が pending のままにならないようにする。
			ctx, cancel := context.WithTimeout(context.WithoutCancel(r.Context()), 3*time.Second)
			defer cancel()
			if err := app.Store.FinishExplanation(ctx, service.UID(r), r.PathValue("id"), r.PathValue("replanId"), optionID, result.Lease, final); err != nil {
				return err
			}
			result = final
		}
		service.JSON(w, 200, result)
		return nil
	})
}
