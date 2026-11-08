package service

import (
	"context"
	"crypto/rand"
	"math"
	"strings"
	"time"
)

func ValidateReplan(input ReplanInput) error {
	if !ValidID(input.CurrentItemID) || (input.DelayMin == nil) == (input.Now == "") {
		return Invalid("currentItemId と、delayMin / now のどちらか一方が必要です")
	}
	if input.DelayMin != nil && (*input.DelayMin < 0 || *input.DelayMin > 600) {
		return Invalid("delayMin は0〜600分で指定してください")
	}
	if input.Now != "" {
		if _, err := time.Parse(time.RFC3339, input.Now); err != nil {
			return Invalid("now は日時で指定してください")
		}
	}
	return nil
}

func DelayedPrefix(trip Itinerary, input ReplanInput) ([]Item, time.Time, error) {
	if err := ValidateReplan(input); err != nil {
		return nil, time.Time{}, err
	}
	index := -1
	for i, item := range trip.Items {
		if item.ItemID == input.CurrentItemID {
			index = i
			break
		}
	}
	if index < 0 || trip.Items[index].Status == "done" {
		return nil, time.Time{}, Invalid("currentItemId が不正です")
	}
	end, err := time.Parse(time.RFC3339, trip.Items[index].EndAt)
	if err != nil {
		return nil, time.Time{}, Upstream()
	}
	delay := 0
	if input.DelayMin != nil {
		delay = *input.DelayMin
	} else {
		now, _ := time.Parse(time.RFC3339, input.Now)
		if now.In(JST).Format("2006-01-02") != trip.Date {
			return nil, time.Time{}, Invalid("now は旅行日の日時を指定してください")
		}
		delay = int(math.Max(0, math.Ceil(now.Sub(end).Minutes())))
		if delay > 600 {
			return nil, time.Time{}, Invalid("遅延は600分以内で指定してください")
		}
	}
	end = end.Add(time.Duration(delay) * time.Minute)
	if end.In(JST).Format("2006-01-02") != trip.Date {
		return nil, time.Time{}, Invalid("遅延後の時刻が旅行日を超えています")
	}
	prefix := append([]Item{}, trip.Items[:index+1]...)
	for i := range prefix {
		prefix[i].Status = "done"
	}
	current := &prefix[index]
	current.Status = "current"
	current.EndAt = end.Format(time.RFC3339)
	current.StayMin += delay
	return prefix, end, nil
}

func Changes(old, next Itinerary) []Change {
	byID := map[string]Item{}
	oldIDs := map[string]bool{}
	for _, item := range next.Items {
		byID[item.ItemID] = item
	}
	for _, item := range old.Items {
		oldIDs[item.ItemID] = true
	}
	added := []Item{}
	for _, item := range next.Items {
		if !oldIDs[item.ItemID] {
			added = append(added, item)
		}
	}
	changes := []Change{}
	used := 0
	for _, item := range old.Items {
		after, ok := byID[item.ItemID]
		if !ok {
			if used < len(added) {
				replacement := added[used]
				used++
				changes = append(changes, Change{Type: "replace", ItemID: item.ItemID, Before: &item, After: &replacement})
			} else {
				changes = append(changes, Change{Type: "drop", ItemID: item.ItemID, Before: &item})
			}
			continue
		}
		kind := "keep"
		if item.StartAt != after.StartAt || item.EndAt != after.EndAt {
			kind = "retime"
		}
		changes = append(changes, Change{Type: kind, ItemID: item.ItemID, Before: &item, After: &after})
	}
	return changes
}

// shiftLegFrom は itemID から出る移動を depart 出発に合わせてずらす（遅延で出発が遅れた場合）。
func shiftLegFrom(legs []Leg, itemID string, depart time.Time) []Leg {
	shifted := append([]Leg{}, legs...)
	for i, leg := range shifted {
		if leg.FromItemID != itemID {
			continue
		}
		shifted[i].DepartAt = depart.Format(time.RFC3339)
		shifted[i].ArriveAt = depart.Add(time.Duration(leg.DurationMin) * time.Minute).Format(time.RFC3339)
	}
	return shifted
}

func (a *App) Replan(ctx context.Context, trip Itinerary, input ReplanInput) (Replan, error) {
	empty := Replan{Warnings: []Warning{}, Options: []Option{}}
	prefix, depart, err := DelayedPrefix(trip, input)
	if err != nil {
		return empty, err
	}
	index := len(prefix) - 1
	if prefix[index].EndAt == trip.Items[index].EndAt {
		return empty, nil
	}
	result := Replan{
		ItineraryID: trip.ID, BasedOnVersion: trip.Version, NeedsChange: true,
		ExpiresAt: time.Now().Add(15 * time.Minute).Format(time.RFC3339),
		Warnings:  []Warning{}, Options: []Option{},
		Explanation: Explanation{Status: "pending"}, Explanations: map[string]Explanation{},
	}
	retimeOnly := index+1 == len(trip.Items)
	travel := 0
	for _, leg := range trip.Legs {
		if !retimeOnly && leg.ToItemID == trip.Items[index+1].ItemID {
			travel = leg.DurationMin
		}
	}
	if !retimeOnly {
		nextStart, err := time.Parse(time.RFC3339, trip.Items[index+1].StartAt)
		if err != nil {
			return empty, Upstream()
		}
		retimeOnly = !depart.Add(time.Duration(travel) * time.Minute).After(nextStart)
	}
	arriveBy, err := At(trip.Date, trip.End.ArriveBy)
	if err != nil {
		return empty, Upstream()
	}
	warnedEnd := false
	warnEnd := func(candidate Itinerary) {
		arrival, err := time.Parse(time.RFC3339, candidate.End.ArriveAt)
		if err == nil && arrival.After(arriveBy) && !warnedEnd {
			warnedEnd = true
			result.Warnings = append(result.Warnings, Warning{Type: "end_at_risk", ItemID: prefix[index].ItemID, Message: arriveBy.Format("15:04") + " までに" + candidate.End.Name + "に戻れません"})
		}
	}
	if retimeOnly {
		candidate := trip
		candidate.Items = append(prefix, trip.Items[index+1:]...)
		candidate.Legs = shiftLegFrom(trip.Legs, prefix[index].ItemID, depart)
		if last := candidate.Legs; len(last) > 0 && last[len(last)-1].ToItemID == "end" {
			candidate.End.ArriveAt = last[len(last)-1].ArriveAt
		}
		summarize(&candidate)
		warnEnd(candidate)
		option := Option{
			OptionID: "op_" + rand.Text(), Source: "algorithm", Label: "時刻だけ調整する", Changes: Changes(trip, candidate),
			SummaryBefore: trip.Summary, SummaryAfter: candidate.Summary,
			Preview: Preview{Items: candidate.Items, Legs: candidate.Legs}, Candidate: candidate,
		}
		result.Options = append(result.Options, option)
		result.Explanations[option.OptionID] = Explanation{Status: "pending"}
		return result, nil
	}
	future := trip.Items[index+1:]
	futureVisits := []Visit{}
	for _, item := range future {
		futureVisits = append(futureVisits, Visit{PlaceID: item.PlaceID, Priority: item.Priority, StayMin: item.StayMin})
	}
	seenPlans := map[string]bool{}
	warned := map[string]bool{}
	addOption := func(selected []Visit, source, label string) error {
		candidate, err := a.suffix(ctx, trip, prefix, depart, selected, true)
		if err != nil {
			return err
		}
		ids := []string{}
		for _, item := range candidate.Items {
			ids = append(ids, item.PlaceID)
		}
		// 組んだ結果が同じになる案は1つにまとめる（先に作ったアルゴリズムの案を残す）。
		if key := strings.Join(ids, "/"); seenPlans[key] {
			return nil
		} else {
			seenPlans[key] = true
		}
		warnEnd(candidate)
		present := map[string]bool{}
		dropped := map[string]bool{}
		for _, item := range candidate.Items {
			present[item.PlaceID] = true
		}
		for _, item := range candidate.Dropped {
			dropped[item.PlaceID] = true
		}
		for _, item := range future {
			if present[item.PlaceID] {
				continue
			}
			if !dropped[item.PlaceID] {
				candidate.Dropped = append(candidate.Dropped, Dropped{PlaceID: item.PlaceID, Name: item.Name, Reason: "遅延後の旅程から除外"})
			}
			if item.Priority == "must" && !warned[item.ItemID] {
				result.Warnings = append(result.Warnings, Warning{Type: "must_at_risk", ItemID: item.ItemID, Message: "必須の予定を残せない案があります"})
				warned[item.ItemID] = true
			}
		}
		option := Option{
			OptionID: "op_" + rand.Text(), Source: source, Label: label, Changes: Changes(trip, candidate),
			SummaryBefore: trip.Summary, SummaryAfter: candidate.Summary,
			Preview: Preview{Items: candidate.Items, Legs: candidate.Legs}, Candidate: candidate,
		}
		result.Options = append(result.Options, option)
		result.Explanations[option.OptionID] = Explanation{Status: "pending"}
		return nil
	}

	// アルゴリズムの案1: 順番はそのままで時刻を後ろにずらす。入らない予定は優先度の低い順に外れる。
	if err := addOption(futureVisits, "algorithm", "順番はそのままで時刻をずらす"); err != nil {
		return empty, err
	}
	// アルゴリズムの案2: 優先度が最も低い予定（同じなら滞在が長い方）を1つ外し、後の予定を守る。
	if skip := lowestPriority(futureVisits); skip >= 0 {
		selected := append(append([]Visit{}, futureVisits[:skip]...), futureVisits[skip+1:]...)
		// 組み立てに失敗しても（Maps の一時的な失敗など）、作成済みの案は返す。
		_ = addOption(selected, "algorithm", "「"+future[skip].Name+"」を外して後の予定を守る")
	}
	// Gemini の案: 近くの代替施設も使って、遅延箇所以降を組み直す。AI の応答の失敗や、
	// 代替施設の詳細取得・経路検索の失敗はその案だけを飛ばし、作成済みの案は返す。
	for _, proposal := range a.aiReplanProposals(ctx, trip, prefix, future, depart) {
		if len(result.Options) >= MaxReplanOptions {
			break
		}
		_ = addOption(proposal.Visits, "ai", proposal.Label)
	}
	for _, leg := range trip.Legs {
		if leg.ToItemID == trip.Items[index+1].ItemID && leg.LineName != nil {
			result.Warnings = append(result.Warnings, Warning{Type: "miss_transit", ItemID: trip.Items[index+1].ItemID, Message: "予定していた公共交通の移動に間に合わない可能性があります"})
			break
		}
	}
	return result, nil
}

// 組み直し案の件数。AI の案は最大3案（API仕様）、アルゴリズムの案（最大2案）と合わせて最大5案。
const (
	MaxAIReplanOptions = 3
	MaxReplanOptions   = 5
)

// lowestPriority は外す候補の位置を返す。must しかなければ -1。
func lowestPriority(visits []Visit) int {
	rank := map[string]int{"optional": 2, "want": 1}
	best := -1
	for i, visit := range visits {
		r, ok := rank[visit.Priority]
		if !ok {
			continue
		}
		if best < 0 || r > rank[visits[best].Priority] || (r == rank[visits[best].Priority] && visit.StayMin > visits[best].StayMin) {
			best = i
		}
	}
	return best
}

type aiProposal struct {
	Visits []Visit
	Label  string
}

// aiReplanProposals は Gemini に遅延後の代替案を最大3つ作らせる。施設IDは enum で残りの予定と
// 近くの代替施設に限り、正規化できない案は捨てる。Maps や Gemini の失敗時は空を返す。
func (a *App) aiReplanProposals(ctx context.Context, trip Itinerary, prefix, future []Item, depart time.Time) []aiProposal {
	if a.AI == nil {
		return nil
	}
	current := prefix[len(prefix)-1]
	origin, err := a.Maps.Details(ctx, current.PlaceID)
	if err != nil {
		return nil
	}
	alternatives, err := a.Maps.Search(ctx, "短時間で訪問できる近くの観光施設", &origin.Location)
	if err != nil {
		return nil
	}
	visits := map[string]Visit{}
	prior := map[string]bool{}
	for _, item := range prefix {
		prior[item.PlaceID] = true
	}
	ids := []string{}
	type remainingFact struct {
		PlaceID  string `json:"placeId"`
		Name     string `json:"name"`
		Priority string `json:"priority"`
		StayMin  int    `json:"stayMin"`
		StartAt  string `json:"plannedStartAt"`
	}
	type alternativeFact struct {
		PlaceID    string  `json:"placeId"`
		Name       string  `json:"name"`
		DistanceKm float64 `json:"distanceKmFromCurrent"`
	}
	remaining := []remainingFact{}
	for _, item := range future {
		visits[item.PlaceID] = Visit{PlaceID: item.PlaceID, Priority: item.Priority, StayMin: item.StayMin}
		ids = append(ids, item.PlaceID)
		remaining = append(remaining, remainingFact{PlaceID: item.PlaceID, Name: item.Name, Priority: item.Priority, StayMin: item.StayMin, StartAt: item.StartAt})
	}
	facts := []alternativeFact{}
	for _, place := range alternatives {
		if _, exists := visits[place.PlaceID]; exists || prior[place.PlaceID] {
			continue
		}
		visits[place.PlaceID] = Visit{PlaceID: place.PlaceID, Priority: "want", StayMin: 30}
		ids = append(ids, place.PlaceID)
		facts = append(facts, alternativeFact{PlaceID: place.PlaceID, Name: place.Name, DistanceKm: math.Round(distance(origin.Location, place.Location)/100) / 10})
	}
	var output struct {
		Options []struct {
			Label    string   `json:"label"`
			PlaceIDs []string `json:"placeIds"`
		} `json:"options"`
	}
	schema := ObjectSchema(map[string]any{
		"options": map[string]any{
			"type": "array", "minItems": 1, "maxItems": MaxAIReplanOptions,
			"items": ObjectSchema(map[string]any{
				"label":    map[string]any{"type": "string"},
				"placeIds": IDArraySchema(ids, 0, len(future)),
			}),
		},
	})
	prompt := Prompt{
		Task: "遅延した旅程の、現在の予定より後ろの部分を組み直す案を最大3つ作ってください。",
		Rules: []string{
			"各案の placeIds は remaining と alternatives の placeId だけを使い、1案の中で重複させない。並びが訪問順になる。",
			"priority が must の予定はできる限り残す。外す場合は want・optional を先に外す。",
			"代替施設（alternatives）は、外した元の予定の数以内で、distanceKmFromCurrent が近いものを使う。",
			"案どうしは考え方を変える（例: 代替施設に置き換える、順番を入れ替える、遠い予定をやめて近場で過ごす）。",
			"最後に end へ end.arriveBy までに着けるようにする。",
			"label は案の内容を20文字以内で表す（例: 近くの資料館に置き換え）。",
		},
		Data: map[string]any{
			"current":      map[string]any{"name": current.Name, "delayedEndAt": depart.Format(time.RFC3339)},
			"remaining":    remaining,
			"alternatives": facts,
			"end":          map[string]string{"name": trip.End.Name, "arriveBy": trip.End.ArriveBy},
		},
		Temperature: 0.4,
	}
	if err := a.AI.Ask(ctx, prompt, schema, &output); err != nil {
		return nil
	}
	proposals := []aiProposal{}
	for _, option := range output.Options {
		selected := []Visit{}
		seen := map[string]bool{}
		for _, id := range option.PlaceIDs {
			if visit, ok := visits[id]; ok && !seen[id] {
				seen[id] = true
				selected = append(selected, visit)
			}
		}
		if len(option.PlaceIDs) == 0 || len(selected) != len(option.PlaceIDs) || len(selected) > len(future) {
			continue
		}
		label := strings.TrimSpace(option.Label)
		if !Text(label, 1, 30) {
			label = "代替案"
		}
		proposals = append(proposals, aiProposal{Visits: selected, Label: label})
		if len(proposals) >= MaxAIReplanOptions {
			break
		}
	}
	return proposals
}
