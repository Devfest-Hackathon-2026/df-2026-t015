package service

import (
	"context"
	"crypto/rand"
	"encoding/json"
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
			OptionID: "op_" + rand.Text(), Changes: Changes(trip, candidate),
			SummaryBefore: trip.Summary, SummaryAfter: candidate.Summary,
			Preview: Preview{Items: candidate.Items, Legs: candidate.Legs}, Candidate: candidate,
		}
		result.Options = append(result.Options, option)
		result.Explanations[option.OptionID] = Explanation{Status: "pending"}
		return result, nil
	}
	future := trip.Items[index+1:]
	origin, err := a.Maps.Details(ctx, prefix[index].PlaceID)
	if err != nil {
		return empty, err
	}
	alternatives, err := a.Maps.Search(ctx, "短時間で訪問できる近くの観光施設", &origin.Location)
	if err != nil {
		return empty, err
	}
	visits := map[string]Visit{}
	prior := map[string]bool{}
	for _, item := range prefix {
		prior[item.PlaceID] = true
	}
	for _, item := range future {
		visits[item.PlaceID] = Visit{PlaceID: item.PlaceID, Priority: item.Priority, StayMin: item.StayMin}
	}
	verified := []Place{}
	for _, place := range alternatives {
		if _, exists := visits[place.PlaceID]; !exists && !prior[place.PlaceID] {
			visits[place.PlaceID] = Visit{PlaceID: place.PlaceID, Priority: "want", StayMin: 30}
			verified = append(verified, place)
		}
	}
	var output struct {
		Options []struct {
			PlaceIDs []string `json:"placeIds"`
		} `json:"options"`
	}
	schema := ObjectSchema(map[string]any{
		"options": map[string]any{
			"type": "array", "minItems": 1, "maxItems": 3,
			"items": ObjectSchema(map[string]any{
				"placeIds": map[string]any{"type": "array", "maxItems": 10, "items": map[string]string{"type": "string"}},
			}),
		},
	})
	data, _ := json.Marshal(map[string]any{"remaining": future, "alternatives": verified, "departAt": depart, "end": trip.End})
	prompt := "遅延後の旅程の訪問順を最大3案提案してください。remaining の placeId と alternatives の placeId だけを使い、1案内で重複させないでください。mustはできる限り残してください。追加する代替施設の数は除外する元施設の数以内とし、移動を抑えてください。最後に end（終わる場所）へ end.arriveBy までに着けるようにしてください。成立しない施設は除外できます。\n" + string(data)
	if err := a.AI.Generate(ctx, prompt, schema, &output); err != nil {
		return empty, err
	}
	if len(output.Options) < 1 || len(output.Options) > 3 {
		return empty, Upstream()
	}
	signatures := map[string]bool{}
	warned := map[string]bool{}
	for _, proposal := range output.Options {
		if proposal.PlaceIDs == nil || len(proposal.PlaceIDs) > len(future) {
			return empty, Upstream()
		}
		selected := []Visit{}
		seen := map[string]bool{}
		for _, id := range proposal.PlaceIDs {
			visit, ok := visits[id]
			if !ok || seen[id] {
				return empty, Upstream()
			}
			seen[id] = true
			selected = append(selected, visit)
		}
		signature := strings.Join(proposal.PlaceIDs, "/")
		if signatures[signature] {
			continue
		}
		signatures[signature] = true
		candidate, err := a.suffix(ctx, trip, prefix, depart, selected, true)
		if err != nil {
			return empty, err
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
			OptionID: "op_" + rand.Text(), Changes: Changes(trip, candidate),
			SummaryBefore: trip.Summary, SummaryAfter: candidate.Summary,
			Preview: Preview{Items: candidate.Items, Legs: candidate.Legs}, Candidate: candidate,
		}
		result.Options = append(result.Options, option)
		result.Explanations[option.OptionID] = Explanation{Status: "pending"}
	}
	for _, leg := range trip.Legs {
		if leg.ToItemID == trip.Items[index+1].ItemID && leg.LineName != nil {
			result.Warnings = append(result.Warnings, Warning{Type: "miss_transit", ItemID: trip.Items[index+1].ItemID, Message: "予定していた公共交通の移動に間に合わない可能性があります"})
			break
		}
	}
	return result, nil
}
