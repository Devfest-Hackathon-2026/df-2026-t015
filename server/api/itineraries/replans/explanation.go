package replans

import (
	"context"
	"encoding/json"
	"github.com/create-alt/gen-TLE/server/internal/service"
	"net/http"
	"time"
)

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
			data, _ := json.Marshal(option)
			var output struct {
				Text string `json:"text"`
			}
			schema := service.ObjectSchema(map[string]any{"text": map[string]string{"type": "string"}})
			generationErr := app.AI.Generate(r.Context(), "次の旅程変更の理由を日本語で短く説明してください。差分にない事実は追加しないでください。\n"+string(data), schema, &output)
			status := "ready"
			if generationErr != nil || !service.Text(output.Text, 1, 2000) {
				status = "failed"
				output.Text = ""
			}
			final := service.Explanation{Status: status, Text: output.Text}
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
