package service

import (
	"context"
	"encoding/json"
	"time"
)

type AddInput struct {
	PlaceID           string `json:"placeId"`
	StayMin           int    `json:"stayMin"`
	Priority          string `json:"priority"`
	InsertAfterItemID string `json:"insertAfterItemId"`
}

func (a *App) suffix(ctx context.Context, old Itinerary, prefix []Item, depart time.Time, visits []Visit, drop bool) (Itinerary, error) {
	start := old.Start
	if len(prefix) > 0 {
		start.PlaceID = prefix[len(prefix)-1].PlaceID
		start.Name = prefix[len(prefix)-1].Name
	}
	start.DepartAt = depart.In(JST).Format("15:04")
	input := PlanInput{Title: old.Title, Date: old.Date, Start: start, EndBy: old.EndBy, Places: visits}
	places, err := a.Places(ctx, visits, start.PlaceID)
	if err != nil {
		return Itinerary{}, err
	}
	var next Itinerary
	if drop {
		next, err = a.Build(ctx, input, places, visits, true)
	} else {
		next, err = a.schedule(ctx, input, places, visits, map[string]Leg{})
	}
	if err != nil {
		return Itinerary{}, err
	}
	return joinPrefix(old, prefix, next), nil
}

func joinPrefix(old Itinerary, prefix []Item, next Itinerary) Itinerary {
	ReuseItems(old, &next)
	if len(prefix) > 0 && len(next.Legs) > 0 {
		next.Legs[0].FromItemID = prefix[len(prefix)-1].ItemID
	}
	prefixIDs := map[string]bool{}
	for _, item := range prefix {
		prefixIDs[item.ItemID] = true
	}
	legs := []Leg{}
	for _, leg := range old.Legs {
		if prefixIDs[leg.ToItemID] {
			legs = append(legs, leg)
		}
	}
	next.Items = append(append([]Item{}, prefix...), next.Items...)
	next.Legs = append(legs, next.Legs...)
	present := map[string]bool{}
	for _, item := range next.Items {
		present[item.PlaceID] = true
	}
	dropped := []Dropped{}
	for _, item := range append(append([]Dropped{}, old.Dropped...), next.Dropped...) {
		if !present[item.PlaceID] {
			dropped = append(dropped, item)
			present[item.PlaceID] = true
		}
	}
	next.Dropped = dropped
	next.ID = old.ID
	next.Version = old.Version
	next.Start = old.Start
	next.ExpiresAt = old.ExpiresAt
	summarize(&next)
	return next
}

func (a *App) Edit(ctx context.Context, old Itinerary, visits []Visit, endBy string) (Itinerary, error) {
	if len(visits) < 1 || len(visits) > 10 {
		return Itinerary{}, Invalid("places は1〜10件で指定してください")
	}
	if endBy == "" {
		endBy = old.EndBy
	}
	count := 0
	for i, item := range old.Items {
		if item.Status == "done" || item.Status == "current" {
			count = i + 1
		}
	}
	fixed := map[string]Item{}
	for _, item := range old.Items[:count] {
		fixed[item.PlaceID] = item
	}
	remaining := []Visit{}
	seen := map[string]bool{}
	for _, visit := range visits {
		if seen[visit.PlaceID] {
			return Itinerary{}, Invalid("施設IDが重複しています")
		}
		seen[visit.PlaceID] = true
		if item, ok := fixed[visit.PlaceID]; ok {
			if visit.Priority != item.Priority || visit.StayMin != item.StayMin {
				return Itinerary{}, Invalid("完了済み・滞在中の予定は変更できません")
			}
			delete(fixed, visit.PlaceID)
		} else {
			remaining = append(remaining, visit)
		}
	}
	if len(fixed) > 0 {
		return Itinerary{}, Invalid("完了済み・滞在中の予定は削除できません")
	}
	depart, err := time.Parse(time.RFC3339, old.Start.DepartAt)
	if err != nil {
		return Itinerary{}, Upstream()
	}
	start := old.Start
	if count > 0 {
		last := old.Items[count-1]
		depart, err = time.Parse(time.RFC3339, last.EndAt)
		if err != nil {
			return Itinerary{}, Upstream()
		}
		start.PlaceID = last.PlaceID
		start.Name = last.Name
		end, err := At(old.Date, endBy)
		if err != nil {
			return Itinerary{}, Invalid("endBy が不正です")
		}
		if end.Before(depart) {
			return Itinerary{}, infeasible(last.PlaceID)
		}
	}
	old.EndBy = endBy
	if len(remaining) == 0 {
		next := old
		next.Items = []Item{}
		next.Legs = []Leg{}
		next.Dropped = []Dropped{}
		return joinPrefix(old, old.Items[:count], next), nil
	}
	start.DepartAt = depart.In(JST).Format("15:04")
	input := PlanInput{Title: old.Title, Date: old.Date, Start: start, EndBy: endBy, Places: remaining}
	next, err := a.Plan(ctx, input)
	if err != nil {
		return Itinerary{}, err
	}
	return joinPrefix(old, old.Items[:count], next), nil
}

func (a *App) Add(ctx context.Context, old Itinerary, input AddInput) (Itinerary, error) {
	if len(old.Items) >= 10 {
		return Itinerary{}, Invalid("予定は最大10件です")
	}
	index := -1
	for i, item := range old.Items {
		if item.PlaceID == input.PlaceID {
			return Itinerary{}, Invalid("同じ施設は追加できません")
		}
		if item.ItemID == input.InsertAfterItemID {
			index = i
		}
	}
	if index < 0 && input.InsertAfterItemID != "start" {
		return Itinerary{}, Invalid("insertAfterItemId が不正です")
	}
	for i, item := range old.Items {
		if i > index && (item.Status == "done" || item.Status == "current") {
			return Itinerary{}, Invalid("完了済み・滞在中の予定の前には追加できません")
		}
	}
	depart, err := time.Parse(time.RFC3339, old.Start.DepartAt)
	if err != nil {
		return Itinerary{}, Upstream()
	}
	if index >= 0 {
		depart, err = time.Parse(time.RFC3339, old.Items[index].EndAt)
		if err != nil {
			return Itinerary{}, Upstream()
		}
	}
	visits := []Visit{{PlaceID: input.PlaceID, Priority: input.Priority, StayMin: input.StayMin}}
	for _, item := range old.Items[index+1:] {
		visits = append(visits, Visit{PlaceID: item.PlaceID, Priority: item.Priority, StayMin: item.StayMin})
	}
	return a.suffix(ctx, old, old.Items[:index+1], depart, visits, false)
}

type Suggestion struct {
	Place             Place  `json:"place"`
	Reason            string `json:"reason"`
	StayMin           int    `json:"stayMin"`
	Price             Price  `json:"price"`
	InsertAfterItemID string `json:"insertAfterItemId"`
	LegFromPrev       struct {
		Mode        string `json:"mode"`
		DurationMin int    `json:"durationMin"`
	} `json:"legFromPrev"`
}

func (a *App) Suggest(ctx context.Context, trip Itinerary, from, to time.Time, after string) ([]Suggestion, error) {
	if from.In(JST).Format("2006-01-02") != trip.Date || to.In(JST).Format("2006-01-02") != trip.Date || !to.After(from) {
		return nil, Invalid("旅程と同日の空き時間を指定してください")
	}
	index := -1
	for i, item := range trip.Items {
		if after == "" {
			end, err := time.Parse(time.RFC3339, item.EndAt)
			if err != nil {
				return nil, Upstream()
			}
			if !end.After(from) {
				index = i
			}
		} else if item.ItemID == after {
			index = i
		}
	}
	if after != "" && after != "start" && index < 0 {
		return nil, Invalid("afterItemId が不正です")
	}
	previous := trip.Start.PlaceID
	earliest, err := time.Parse(time.RFC3339, trip.Start.DepartAt)
	if err != nil {
		return nil, Upstream()
	}
	if index >= 0 {
		previous = trip.Items[index].PlaceID
		earliest, err = time.Parse(time.RFC3339, trip.Items[index].EndAt)
		if err != nil {
			return nil, Upstream()
		}
	}
	latest, err := At(trip.Date, trip.EndBy)
	if err != nil {
		return nil, Upstream()
	}
	if index+1 < len(trip.Items) {
		latest, err = time.Parse(time.RFC3339, trip.Items[index+1].StartAt)
		if err != nil {
			return nil, Upstream()
		}
	}
	if from.Before(earliest) || to.After(latest) {
		return nil, Invalid("指定した時間帯は空き時間ではありません")
	}
	origin, err := a.Maps.Details(ctx, previous)
	if err != nil {
		return nil, err
	}
	places, err := a.Maps.Search(ctx, "短時間で立ち寄れる観光スポット、公園、カフェ", &origin.Location)
	if err != nil {
		return nil, err
	}
	byID := map[string]Place{}
	existing := map[string]bool{trip.Start.PlaceID: true}
	for _, item := range trip.Items {
		existing[item.PlaceID] = true
	}
	candidates := []Place{}
	for _, place := range places {
		if !existing[place.PlaceID] {
			byID[place.PlaceID] = place
			candidates = append(candidates, place)
		}
	}
	result := []Suggestion{}
	if len(candidates) == 0 {
		return result, nil
	}
	var output struct {
		Suggestions []struct {
			PlaceID string `json:"placeId"`
			Reason  string `json:"reason"`
			StayMin int    `json:"stayMin"`
		} `json:"suggestions"`
	}
	schema := ObjectSchema(map[string]any{
		"suggestions": map[string]any{
			"type": "array", "maxItems": 5,
			"items": ObjectSchema(map[string]any{
				"placeId": map[string]string{"type": "string"},
				"reason":  map[string]string{"type": "string"},
				"stayMin": map[string]any{"type": "integer", "minimum": 10, "maximum": 480},
			}),
		},
	})
	data, _ := json.Marshal(map[string]any{"from": from, "to": to, "candidates": candidates})
	if err := a.AI.Generate(ctx, "空き時間に合う施設を候補から選び、理由と滞在分数を提案してください。候補にない施設IDは使わないでください。\n"+string(data), schema, &output); err != nil {
		return nil, err
	}
	if output.Suggestions == nil || len(output.Suggestions) > 5 {
		return nil, Upstream()
	}
	seen := map[string]bool{}
	for _, selected := range output.Suggestions {
		place, ok := byID[selected.PlaceID]
		if !ok || seen[selected.PlaceID] || selected.StayMin < 10 || selected.StayMin > 480 || !Text(selected.Reason, 1, 500) {
			return nil, Upstream()
		}
		seen[selected.PlaceID] = true
		leg, err := a.Maps.Route(ctx, previous, place.PlaceID, from)
		if err != nil {
			return nil, err
		}
		arrival, err := time.Parse(time.RFC3339, leg.ArriveAt)
		if err != nil {
			return nil, Upstream()
		}
		start, _, ok := OpenAt(place.Hours, arrival, selected.StayMin)
		if !ok {
			continue
		}
		finish := start.Add(time.Duration(selected.StayMin) * time.Minute)
		if finish.After(to) {
			continue
		}
		if index+1 < len(trip.Items) {
			next, err := a.Maps.Route(ctx, place.PlaceID, trip.Items[index+1].PlaceID, finish)
			if err != nil {
				return nil, err
			}
			arrival, err := time.Parse(time.RFC3339, next.ArriveAt)
			if err != nil {
				return nil, Upstream()
			}
			if arrival.After(to) {
				continue
			}
		}
		suggestion := Suggestion{Place: place, Reason: selected.Reason, StayMin: selected.StayMin, Price: Price{Kind: "unknown"}, InsertAfterItemID: "start"}
		if index >= 0 {
			suggestion.InsertAfterItemID = trip.Items[index].ItemID
		}
		suggestion.LegFromPrev.Mode = leg.Mode
		suggestion.LegFromPrev.DurationMin = leg.DurationMin
		result = append(result, suggestion)
	}
	return result, nil
}
