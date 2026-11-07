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

func placeRef(id string) *string { return &id }

// clock は RFC3339 の日時を日本時間の HH:mm にする。
func clock(value string) (string, error) {
	t, err := time.Parse(time.RFC3339, value)
	if err != nil {
		return "", Upstream()
	}
	return t.In(JST).Format("15:04"), nil
}

// suffix は prefix の予定を残し、最後の予定（なければ出発地）から visits を組み直す。
func (a *App) suffix(ctx context.Context, old Itinerary, prefix []Item, depart time.Time, visits []Visit, drop bool) (Itinerary, error) {
	start := old.Start
	if len(prefix) > 0 {
		last := prefix[len(prefix)-1]
		start = Start{PlaceID: placeRef(last.PlaceID), Name: last.Name}
	}
	start.DepartAt = depart.In(JST).Format("15:04")
	end := old.End
	end.ArriveAt = ""
	input := PlanInput{Title: old.Title, Date: old.Date, Start: start, End: end, Places: visits}
	// 終わる場所が placeId だけで渡された（編集で変えた）ときは、施設情報から名前と座標を入れる。
	var endID *string
	if end.PlaceID != nil && (end.Name == "" || end.Location == nil) {
		endID = end.PlaceID
	}
	places, err := a.Places(ctx, visits, start.PlaceID, endID)
	if err != nil {
		return Itinerary{}, err
	}
	if endID != nil {
		place := places[*endID]
		location := place.Location
		input.End.Name, input.End.Location = place.Name, &location
	}
	var next Itinerary
	if drop {
		next, err = a.Build(ctx, input, places, visits, BuildOptions{DropMust: true, LateEnd: true})
	} else {
		next, err = a.schedule(ctx, input, places, visits, map[string]Leg{}, false)
	}
	if err != nil {
		return Itinerary{}, err
	}
	return joinPrefix(old, prefix, next, old.Start), nil
}

// joinPrefix は残す予定（prefix）と組み直した後半（next）をつなぐ。
// next.End（終わる場所に着く時刻）と start（旅程の出発地）を結果に使う。
func joinPrefix(old Itinerary, prefix []Item, next Itinerary, start Start) Itinerary {
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
	next.Title = old.Title
	next.Start = start
	if next.ExpiresAt == "" {
		next.ExpiresAt = old.ExpiresAt
	}
	summarize(&next)
	return next
}

func sameStart(a, b Start) bool {
	return a.Waypoint().Key() == b.Waypoint().Key() && a.DepartAt == b.DepartAt
}

// Edit は PUT /itineraries/:id/places の再生成を行う。
// 旅行日を変えると旅程全体を作り直す。同じ日のままなら完了済み・滞在中の予定を固定し、残りだけを作り直す。
func (a *App) Edit(ctx context.Context, old Itinerary, input EditInput) (Itinerary, error) {
	if err := ValidateVisits(input.Places); err != nil {
		return Itinerary{}, err
	}
	date := old.Date
	if input.Date != nil {
		date = *input.Date
	}
	start := old.Start
	departAt, err := clock(old.Start.DepartAt)
	if err != nil {
		return Itinerary{}, err
	}
	start.DepartAt = departAt
	if input.Start != nil {
		start = *input.Start
	}
	end := old.End
	end.ArriveAt = ""
	if input.End != nil {
		end = *input.End
		end.ArriveAt = ""
	}
	// 施設で指定された出発地・終わる場所は、作り直すときに施設情報から名前と座標を入れ直す。
	if start.PlaceID != nil {
		start.Name, start.Location = "", nil
	}
	if end.PlaceID != nil {
		end.Name, end.Location = "", nil
	}
	allowed := map[string]bool{}
	for _, visit := range input.Places {
		allowed[visit.PlaceID] = true
	}
	kept := []Dropped{}
	for _, item := range old.Dropped {
		if allowed[item.PlaceID] {
			kept = append(kept, item)
		}
	}
	old.Dropped = kept

	if date != old.Date {
		plan := PlanInput{Title: old.Title, Date: date, Start: start, End: end, Places: input.Places}
		next, err := a.Plan(ctx, plan)
		if err != nil {
			return Itinerary{}, err
		}
		ReuseItems(old, &next)
		for i := range next.Items {
			next.Items[i].Status = "upcoming"
		}
		next.ID, next.Version = old.ID, old.Version
		return next, nil
	}

	count := 0
	for i, item := range old.Items {
		if item.Status == "done" || item.Status == "current" {
			count = i + 1
		}
	}
	if count == 0 {
		plan := PlanInput{Title: old.Title, Date: date, Start: start, End: end, Places: input.Places}
		next, err := a.Plan(ctx, plan)
		if err != nil {
			return Itinerary{}, err
		}
		return joinPrefix(old, nil, next, next.Start), nil
	}

	if input.Start != nil {
		current := old.Start
		current.DepartAt = departAt
		if !sameStart(current, *input.Start) {
			return Itinerary{}, Invalid("旅程の開始後は出発地・出発時刻を変更できません")
		}
	}
	if _, err := ValidateEnd(date, end); err != nil {
		return Itinerary{}, err
	}
	fixed := map[string]Item{}
	for _, item := range old.Items[:count] {
		fixed[item.PlaceID] = item
	}
	remaining := []Visit{}
	for _, visit := range input.Places {
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
	last := old.Items[count-1]
	depart, err := time.Parse(time.RFC3339, last.EndAt)
	if err != nil {
		return Itinerary{}, Upstream()
	}
	old.End = end
	if len(remaining) == 0 {
		return a.suffix(ctx, old, old.Items[:count], depart, nil, false)
	}
	plan := PlanInput{Title: old.Title, Date: date, Start: Start{PlaceID: placeRef(last.PlaceID), Name: last.Name, DepartAt: depart.In(JST).Format("15:04")}, End: end, Places: remaining}
	next, err := a.Plan(ctx, plan)
	if err != nil {
		return Itinerary{}, err
	}
	return joinPrefix(old, old.Items[:count], next, old.Start), nil
}

// Add は施設を insertAfterItemId の後ろに追加する。insertAfterItemId が空なら最後の予定の後ろに追加する。
func (a *App) Add(ctx context.Context, old Itinerary, input AddInput) (Itinerary, error) {
	if len(old.Items) >= 10 {
		return Itinerary{}, Invalid("予定は最大10件です")
	}
	index := -1
	if input.InsertAfterItemID == "" {
		index = len(old.Items) - 1
	}
	for i, item := range old.Items {
		if item.PlaceID == input.PlaceID {
			return Itinerary{}, Invalid("同じ施設は追加できません")
		}
		if item.ItemID == input.InsertAfterItemID {
			index = i
		}
	}
	if index < 0 && input.InsertAfterItemID != "start" && input.InsertAfterItemID != "" {
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

// locate は地点の座標を返す。施設なら Places Details で取得する。
func (a *App) locate(ctx context.Context, point Waypoint) (Point, error) {
	if point.PlaceID == "" {
		return point.Location, nil
	}
	place, err := a.Maps.Details(ctx, point.PlaceID)
	if err != nil {
		return Point{}, err
	}
	return place.Location, nil
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
	previous := trip.Start.Waypoint()
	earliest, err := time.Parse(time.RFC3339, trip.Start.DepartAt)
	if err != nil {
		return nil, Upstream()
	}
	if index >= 0 {
		previous = Waypoint{PlaceID: trip.Items[index].PlaceID}
		earliest, err = time.Parse(time.RFC3339, trip.Items[index].EndAt)
		if err != nil {
			return nil, Upstream()
		}
	}
	// 次の予定がなければ、終わる場所に着きたい時刻までが空き時間になる。
	next := trip.End.Waypoint()
	latest, err := At(trip.Date, trip.End.ArriveBy)
	if err != nil {
		return nil, Upstream()
	}
	if index+1 < len(trip.Items) {
		next = Waypoint{PlaceID: trip.Items[index+1].PlaceID}
		latest, err = time.Parse(time.RFC3339, trip.Items[index+1].StartAt)
		if err != nil {
			return nil, Upstream()
		}
	}
	if from.Before(earliest) || to.After(latest) {
		return nil, Invalid("指定した時間帯は空き時間ではありません")
	}
	origin, err := a.locate(ctx, previous)
	if err != nil {
		return nil, err
	}
	places, err := a.Maps.Search(ctx, "短時間で立ち寄れる観光スポット、公園、カフェ", &origin)
	if err != nil {
		return nil, err
	}
	byID := map[string]Place{}
	existing := map[string]bool{}
	for _, id := range []*string{trip.Start.PlaceID, trip.End.PlaceID} {
		if id != nil {
			existing[*id] = true
		}
	}
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
		leg, err := a.Maps.Route(ctx, previous, Waypoint{PlaceID: place.PlaceID}, from)
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
		// 次の予定（最後なら終わる場所）へ、空き時間の終わりまでに着けるものだけを返す。
		onward, err := a.Maps.Route(ctx, Waypoint{PlaceID: place.PlaceID}, next, finish)
		if err != nil {
			return nil, err
		}
		arrival, err = time.Parse(time.RFC3339, onward.ArriveAt)
		if err != nil {
			return nil, Upstream()
		}
		if arrival.After(to) {
			continue
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
