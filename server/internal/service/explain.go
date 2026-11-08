package service

import (
	"context"
	"strings"
	"time"
)

// changeFact は理由文の材料。案の changes からサーバーが計算した事実だけを入れ、AI には言い換えだけを任せる。
type changeFact struct {
	ItemID       string `json:"itemId"`
	Type         string `json:"type"`
	Before       string `json:"before,omitempty"`
	After        string `json:"after,omitempty"`
	Priority     string `json:"priority,omitempty"`
	ShiftMin     *int   `json:"shiftMin,omitempty"`
	BeforeStart  string `json:"beforeStart,omitempty"`
	AfterStart   string `json:"afterStart,omitempty"`
	ExtendedMin  *int   `json:"extendedStayMin,omitempty"`
	DroppedCause string `json:"droppedCause,omitempty"`
}

func minutesBetween(before, after string) *int {
	a, err1 := time.Parse(time.RFC3339, before)
	b, err2 := time.Parse(time.RFC3339, after)
	if err1 != nil || err2 != nil {
		return nil
	}
	value := int(b.Sub(a).Minutes())
	return &value
}

func hhmm(value string) string {
	t, err := time.Parse(time.RFC3339, value)
	if err != nil {
		return ""
	}
	return t.In(JST).Format("15:04")
}

// ExplanationFacts は案の変更点を、理由文に使える事実の一覧にする。
func ExplanationFacts(proposal Replan, option Option) map[string]any {
	facts := []changeFact{}
	dropped := map[string]string{}
	for _, item := range option.Candidate.Dropped {
		dropped[item.PlaceID] = item.Reason
	}
	for _, change := range option.Changes {
		fact := changeFact{ItemID: change.ItemID, Type: change.Type}
		if change.Before != nil {
			fact.Before = change.Before.Name
			fact.Priority = change.Before.Priority
			fact.BeforeStart = hhmm(change.Before.StartAt)
		}
		if change.After != nil {
			fact.After = change.After.Name
			fact.AfterStart = hhmm(change.After.StartAt)
		}
		if change.Before != nil && change.After != nil {
			if change.Type == "retime" {
				fact.ShiftMin = minutesBetween(change.Before.StartAt, change.After.StartAt)
			}
			if extended := change.After.StayMin - change.Before.StayMin; extended > 0 {
				fact.ExtendedMin = &extended
			}
		}
		if change.Type == "drop" && change.Before != nil {
			fact.DroppedCause = dropped[change.Before.PlaceID]
		}
		facts = append(facts, fact)
	}
	warnings := []string{}
	for _, warning := range proposal.Warnings {
		warnings = append(warnings, warning.Type+": "+warning.Message)
	}
	return map[string]any{
		"option":   map[string]string{"label": option.Label, "source": option.Source},
		"changes":  facts,
		"before":   map[string]any{"moveMin": option.SummaryBefore.MoveMin, "endAt": hhmm(option.SummaryBefore.EndAt)},
		"after":    map[string]any{"moveMin": option.SummaryAfter.MoveMin, "endAt": hhmm(option.SummaryAfter.EndAt)},
		"warnings": warnings,
	}
}

// Explain は組み直し案の変更理由を作る。全体の要約（text）と、keep 以外の変更ごとの理由（reasons）を返す。
// 理由の itemId は案の changes にあるものだけを受け付け、種類はサーバー側の値を使う。
func (a *App) Explain(ctx context.Context, proposal Replan, option Option) (Explanation, error) {
	types := map[string]string{}
	ids := []string{}
	for _, change := range option.Changes {
		if change.Type == "keep" {
			continue
		}
		types[change.ItemID] = change.Type
		ids = append(ids, change.ItemID)
	}
	reasonItem := ObjectSchema(map[string]any{
		"itemId": map[string]any{"type": "string"},
		"reason": map[string]any{"type": "string"},
	})
	if len(ids) > 0 {
		reasonItem["properties"].(map[string]any)["itemId"] = map[string]any{"type": "string", "enum": ids}
	}
	schema := ObjectSchema(map[string]any{
		"summary": map[string]any{"type": "string"},
		"reasons": map[string]any{"type": "array", "maxItems": len(ids), "items": reasonItem},
	})
	prompt := Prompt{
		Task: "旅程の組み直し案について、利用者に見せる変更理由を日本語で書いてください。",
		Rules: []string{
			"summary は案全体の理由を1〜2文、120文字程度で書く。遅れの影響と、この案で何を守った・諦めたかを伝える。",
			"reasons には changes のうち keep 以外の変更を1件ずつ、itemId と理由（60文字程度）で書く。",
			"使ってよい事実は入力データだけ。shiftMin は開始時刻のずれ（分）、extendedStayMin は遅れで延びた滞在（分）、droppedCause は外れた理由。",
			"入力にない施設の魅力・料金・混雑・天気などは書かない。です・ます調で書く。",
		},
		Data:        ExplanationFacts(proposal, option),
		Temperature: 0.4,
	}
	var output struct {
		Summary string `json:"summary"`
		Reasons []struct {
			ItemID string `json:"itemId"`
			Reason string `json:"reason"`
		} `json:"reasons"`
	}
	if err := a.AI.Ask(ctx, prompt, schema, &output); err != nil {
		return Explanation{Status: "failed"}, err
	}
	summary := strings.TrimSpace(output.Summary)
	if !Text(summary, 1, 2000) {
		return Explanation{Status: "failed"}, Upstream()
	}
	result := Explanation{Status: "ready", Text: summary, Reasons: []ExplanationReason{}}
	seen := map[string]bool{}
	for _, reason := range output.Reasons {
		kind, ok := types[reason.ItemID]
		text := strings.TrimSpace(reason.Reason)
		if !ok || seen[reason.ItemID] || !Text(text, 1, 500) {
			continue
		}
		seen[reason.ItemID] = true
		result.Reasons = append(result.Reasons, ExplanationReason{ItemID: reason.ItemID, Type: kind, Reason: text})
	}
	return result, nil
}
