package service

import (
	"context"
	"math"
	"sort"
	"strings"
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
	date := old.Date
	if input.Date != nil {
		date = *input.Date
	}
	count := 0
	for i, item := range old.Items {
		if item.Status == "done" || item.Status == "current" {
			count = i + 1
		}
	}
	// 同じ日のまま編集するときは、完了済み・滞在中の予定をそのまま送り直せるようにする
	// （遅延で延びた滞在時間が480分を超えていても受け付ける）。旅行日を変えると全体を作り直すので通常どおり確認する。
	fixedStay := map[string]int{}
	if date == old.Date {
		for _, item := range old.Items[:count] {
			fixedStay[item.PlaceID] = item.StayMin
		}
	}
	if err := validateVisits(input.Places, fixedStay); err != nil {
		return Itinerary{}, err
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

	if count == 0 {
		plan := PlanInput{Title: old.Title, Date: date, Start: start, End: end, Places: input.Places}
		next, err := a.replanPart(ctx, plan, old.Items, nil)
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
	next, err := a.replanPart(ctx, plan, old.Items[count:], old.Items[:count])
	if err != nil {
		return Itinerary{}, err
	}
	return joinPrefix(old, old.Items[:count], next, old.Start), nil
}

// replanPart は編集後の行き先（input.Places）を、今の順番（current）を基準に部分的に組み直す。
// 基準の順番は「変更のない施設は今の順番のまま、追加された施設を最小コストの位置に挿入」したもの。
// Gemini には固定の予定と変更点を渡して並べ直させ、両方を組んで良い方を採る。
func (a *App) replanPart(ctx context.Context, input PlanInput, current []Item, fixed []Item) (Itinerary, error) {
	if err := ValidatePlan(input); err != nil {
		return Itinerary{}, err
	}
	places, err := a.Places(ctx, input.Places, input.Start.PlaceID, input.End.PlaceID)
	if err != nil {
		return Itinerary{}, err
	}
	fillEndpoints(&input, places)
	byID := map[string]Visit{}
	for _, visit := range input.Places {
		byID[visit.PlaceID] = visit
	}
	edit := &editContext{FixedItems: []string{}, CurrentOrder: []string{}, Added: []string{}, Removed: []string{}, Updated: []string{}}
	for _, item := range fixed {
		edit.FixedItems = append(edit.FixedItems, item.Name)
	}
	kept := []Visit{}
	inCurrent := map[string]bool{}
	for _, item := range current {
		inCurrent[item.PlaceID] = true
		edit.CurrentOrder = append(edit.CurrentOrder, item.PlaceID)
		visit, ok := byID[item.PlaceID]
		if !ok {
			edit.Removed = append(edit.Removed, item.Name)
			continue
		}
		kept = append(kept, visit)
		if visit.Priority != item.Priority || visit.StayMin != item.StayMin {
			edit.Updated = append(edit.Updated, item.PlaceID)
		}
	}
	added := []Visit{}
	for _, visit := range input.Places {
		if !inCurrent[visit.PlaceID] {
			added = append(added, visit)
			edit.Added = append(edit.Added, visit.PlaceID)
		}
	}
	base := InsertCheapest(*input.Start.Location, input.End.Location, kept, added, places)
	return a.arrange(ctx, arrangeRequest{Input: input, Places: places, Base: base, Prompt: orderPrompt(input, places, base, edit)})
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
	TypeLabel         string `json:"typeLabel,omitempty"`
	Reason            string `json:"reason"`
	StayMin           int    `json:"stayMin"`
	Price             Price  `json:"price"`
	InsertAfterItemID string `json:"insertAfterItemId"`
	LegFromPrev       struct {
		Mode        string `json:"mode"`
		DurationMin int    `json:"durationMin"`
	} `json:"legFromPrev"`
	// LegToNext は次の予定（最後の予定の後なら終わる場所）への移動。
	LegToNext struct {
		Mode        string `json:"mode"`
		DurationMin int    `json:"durationMin"`
	} `json:"legToNext"`
}

// Idea は施設を決めない、空き時間の過ごし方のおすすめ（例: 駅前のカフェで休憩する）。
type Idea struct {
	Title       string `json:"title"`
	Description string `json:"description"`
	DurationMin int    `json:"durationMin"`
}

type SuggestResult struct {
	Suggestions []Suggestion `json:"suggestions"`
	Ideas       []Idea       `json:"ideas"`
}

// suggestMask は空き時間の候補探しに使う項目。営業時間も取得する。
const suggestMask = nearbyMask + ",places.regularOpeningHours"

// minimumStay はこれより短くしか過ごせない場所は提案しない（分）。
const minimumStay = 15

// gapCandidate は空き時間の候補。前後の移動時間を差し引いた、滞在に使える時間を持つ。
type gapCandidate struct {
	Place        Place
	TypeLabel    string
	In, Out      Leg
	AvailableMin int
	Hours        *OpeningHours
}

// Suggest は空き時間 from〜to の使い方を提案する（F-07）。
//  1. 直前の予定（なければ出発地）の周辺を Nearby Search で探し、直線距離で近い順に絞る。
//  2. 各候補について前後の移動時間を Routes で求め、空き時間から差し引いた「滞在に使える時間」を出す。
//     その時間が minimumStay 分に満たない候補や、営業時間外の候補はここで除く。
//  3. Gemini が候補から最大5件を選び、滞在に使える時間以内の stayMin と理由をつける。
//     あわせて、施設を決めない過ごし方（ideas）を最大5件返す。
//  4. 選ばれた候補を実際の時刻で検証し、次の予定に間に合うものだけ返す。
func (a *App) Suggest(ctx context.Context, trip Itinerary, from, to time.Time, after string) (SuggestResult, error) {
	empty := SuggestResult{Suggestions: []Suggestion{}, Ideas: []Idea{}}
	if from.In(JST).Format("2006-01-02") != trip.Date || to.In(JST).Format("2006-01-02") != trip.Date || !to.After(from) {
		return empty, Invalid("旅程と同日の空き時間を指定してください")
	}
	index := -1
	for i, item := range trip.Items {
		if after == "" {
			end, err := time.Parse(time.RFC3339, item.EndAt)
			if err != nil {
				return empty, Upstream()
			}
			if !end.After(from) {
				index = i
			}
		} else if item.ItemID == after {
			index = i
		}
	}
	if after != "" && after != "start" && index < 0 {
		return empty, Invalid("afterItemId が不正です")
	}
	previous := trip.Start.Waypoint()
	previousName := trip.Start.Name
	earliest, err := time.Parse(time.RFC3339, trip.Start.DepartAt)
	if err != nil {
		return empty, Upstream()
	}
	if index >= 0 {
		previous = Waypoint{PlaceID: trip.Items[index].PlaceID}
		previousName = trip.Items[index].Name
		earliest, err = time.Parse(time.RFC3339, trip.Items[index].EndAt)
		if err != nil {
			return empty, Upstream()
		}
	}
	// 次の予定がなければ、終わる場所に着きたい時刻までが空き時間になる。
	next := trip.End.Waypoint()
	nextName := trip.End.Name
	latest, err := At(trip.Date, trip.End.ArriveBy)
	if err != nil {
		return empty, Upstream()
	}
	if index+1 < len(trip.Items) {
		next = Waypoint{PlaceID: trip.Items[index+1].PlaceID}
		nextName = trip.Items[index+1].Name
		latest, err = time.Parse(time.RFC3339, trip.Items[index+1].StartAt)
		if err != nil {
			return empty, Upstream()
		}
	}
	if from.Before(earliest) || to.After(latest) {
		return empty, Invalid("指定した時間帯は空き時間ではありません")
	}
	origin, err := a.locate(ctx, previous)
	if err != nil {
		return empty, err
	}
	window := int(to.Sub(from).Minutes())
	candidates, err := a.gapCandidates(ctx, trip, previous, next, origin, from, to)
	if err != nil {
		return empty, err
	}
	byID := map[string]gapCandidate{}
	ids := []string{}
	type candidateFact struct {
		PlaceID      string        `json:"placeId"`
		Name         string        `json:"name"`
		TypeLabel    string        `json:"typeLabel"`
		TravelInMin  int           `json:"travelInMin"`
		TravelOutMin int           `json:"travelOutMin"`
		AvailableMin int           `json:"availableMin"`
		OpeningHours *OpeningHours `json:"openingHours"`
	}
	facts := []candidateFact{}
	for _, c := range candidates {
		byID[c.Place.PlaceID] = c
		ids = append(ids, c.Place.PlaceID)
		facts = append(facts, candidateFact{PlaceID: c.Place.PlaceID, Name: c.Place.Name, TypeLabel: c.TypeLabel, TravelInMin: c.In.DurationMin, TravelOutMin: c.Out.DurationMin, AvailableMin: c.AvailableMin, OpeningHours: c.Hours})
	}
	properties := map[string]any{
		"ideas": map[string]any{
			"type": "array", "maxItems": 5,
			"items": ObjectSchema(map[string]any{
				"title":       map[string]any{"type": "string"},
				"description": map[string]any{"type": "string"},
				"durationMin": map[string]any{"type": "integer", "minimum": 5, "maximum": window},
			}),
		},
	}
	if len(ids) > 0 {
		properties["suggestions"] = map[string]any{
			"type": "array", "maxItems": 5,
			"items": ObjectSchema(map[string]any{
				"placeId": map[string]any{"type": "string", "enum": ids},
				"reason":  map[string]any{"type": "string"},
				"stayMin": map[string]any{"type": "integer", "minimum": 10, "maximum": 480},
			}),
		}
	}
	prompt := Prompt{
		Task: "旅程の空き時間の使い方を提案してください。",
		Rules: []string{
			"suggestions は candidates から、空き時間を十分に楽しめる施設を最大5件選ぶ。availableMin（前後の移動時間を除いて滞在に使える分数）が短すぎて慌ただしくなる施設は選ばない。",
			"stayMin は availableMin 以内にし、その施設で過ごすのにちょうどよい分数にする。",
			"reason は、その施設で何ができるか・なぜこの空き時間に合うかを40文字程度で書く。typeLabel と移動時間など入力の事実だけを根拠にする。",
			"ideas は施設を決めない時間の過ごし方を3〜5件出す（例: 駅前で軽く散歩する、カフェで次の予定を確認する）。durationMin は空き時間（windowMin）以内にする。",
			"previous（直前の場所）と next（次の目的地）の間で無理なくできることにする。",
		},
		Data: map[string]any{
			"windowMin":  window,
			"from":       from.In(JST).Format("15:04"),
			"to":         to.In(JST).Format("15:04"),
			"previous":   previousName,
			"next":       nextName,
			"candidates": facts,
		},
		Temperature: 0.5,
	}
	var output struct {
		Suggestions []struct {
			PlaceID string `json:"placeId"`
			Reason  string `json:"reason"`
			StayMin int    `json:"stayMin"`
		} `json:"suggestions"`
		Ideas []Idea `json:"ideas"`
	}
	if err := a.AI.Ask(ctx, prompt, ObjectSchema(properties), &output); err != nil {
		return empty, err
	}
	if output.Ideas == nil || (len(ids) > 0 && output.Suggestions == nil) {
		return empty, Upstream()
	}
	result := SuggestResult{Suggestions: []Suggestion{}, Ideas: []Idea{}}
	for _, idea := range output.Ideas {
		if Text(idea.Title, 1, 60) && Text(idea.Description, 1, 300) && idea.DurationMin >= 5 && idea.DurationMin <= window && len(result.Ideas) < 5 {
			result.Ideas = append(result.Ideas, idea)
		}
	}
	seen := map[string]bool{}
	for _, selected := range output.Suggestions {
		c, ok := byID[selected.PlaceID]
		if !ok || seen[selected.PlaceID] || !Text(selected.Reason, 1, 500) || len(result.Suggestions) >= 5 {
			continue
		}
		seen[selected.PlaceID] = true
		// AI の滞在時間が使える時間を超えたら、使える時間に収める。
		stay := min(selected.StayMin, c.AvailableMin)
		if stay < minimumStay {
			continue
		}
		arrival, err := time.Parse(time.RFC3339, c.In.ArriveAt)
		if err != nil {
			return empty, Upstream()
		}
		start, _, ok := OpenAt(c.Place.Hours, arrival, stay)
		if !ok {
			continue
		}
		// 実際の出発時刻で次への移動を調べる。間に合わなければ、遅れた分だけ滞在を短くして1回だけ調べ直す。
		var onward Leg
		fits := false
		for range 2 {
			onward, err = a.Maps.Route(ctx, Waypoint{PlaceID: c.Place.PlaceID}, next, start.Add(time.Duration(stay)*time.Minute))
			if err != nil {
				return empty, err
			}
			reach, err := time.Parse(time.RFC3339, onward.ArriveAt)
			if err != nil {
				return empty, Upstream()
			}
			if !reach.After(to) {
				fits = true
				break
			}
			stay -= int(math.Ceil(reach.Sub(to).Minutes()))
			if stay < minimumStay {
				break
			}
		}
		if !fits {
			continue
		}
		suggestion := Suggestion{Place: c.Place, TypeLabel: c.TypeLabel, Reason: strings.TrimSpace(selected.Reason), StayMin: stay, Price: Price{Kind: "unknown"}, InsertAfterItemID: "start"}
		if index >= 0 {
			suggestion.InsertAfterItemID = trip.Items[index].ItemID
		}
		suggestion.LegFromPrev.Mode, suggestion.LegFromPrev.DurationMin = c.In.Mode, c.In.DurationMin
		suggestion.LegToNext.Mode, suggestion.LegToNext.DurationMin = onward.Mode, onward.DurationMin
		result.Suggestions = append(result.Suggestions, suggestion)
	}
	return result, nil
}

// gapCandidates は空き時間に寄れる候補を探し、前後の移動時間と滞在に使える時間を求める。
func (a *App) gapCandidates(ctx context.Context, trip Itinerary, previous, next Waypoint, origin Point, from, to time.Time) ([]gapCandidate, error) {
	window := int(to.Sub(from).Minutes())
	if window < minimumStay {
		return nil, nil
	}
	// 徒歩（約80m/分）で空き時間の3分の1以内に着ける範囲を目安に探す。
	radius := min(max(window/3*80, 300), 3000)
	found, err := a.Maps.nearby(ctx, origin, radius, "", suggestMask)
	if err != nil {
		return nil, err
	}
	existing := map[string]bool{}
	for _, id := range []*string{trip.Start.PlaceID, trip.End.PlaceID} {
		if id != nil {
			existing[*id] = true
		}
	}
	for _, item := range trip.Items {
		existing[item.PlaceID] = true
	}
	options := []nearbyResult{}
	for _, value := range found {
		if !existing[value.Place.PlaceID] {
			options = append(options, value)
		}
	}
	// Routes の呼び出しを抑えるため、直線距離で近い8件だけ移動時間を調べる。
	sort.SliceStable(options, func(i, j int) bool {
		return distance(origin, options[i].Place.Location) < distance(origin, options[j].Place.Location)
	})
	if len(options) > 8 {
		options = options[:8]
	}
	day, _ := time.ParseInLocation("2006-01-02", trip.Date, JST)
	candidates := []gapCandidate{}
	for _, value := range options {
		in, err := a.Maps.Route(ctx, previous, Waypoint{PlaceID: value.Place.PlaceID}, from)
		if err != nil {
			return nil, err
		}
		arrival, err := time.Parse(time.RFC3339, in.ArriveAt)
		if err != nil {
			return nil, Upstream()
		}
		start, _, ok := OpenAt(value.Place.Hours, arrival, minimumStay)
		if !ok {
			continue
		}
		// 次への移動は、着いて最短の滞在をしたあとに出発する時刻で調べる（公共交通は出発時刻で待ち時間が変わるため）。
		out, err := a.Maps.Route(ctx, Waypoint{PlaceID: value.Place.PlaceID}, next, start.Add(minimumStay*time.Minute))
		if err != nil {
			return nil, err
		}
		available := int(to.Sub(start).Minutes()) - out.DurationMin
		if available < minimumStay {
			continue
		}
		candidates = append(candidates, gapCandidate{Place: value.Place, TypeLabel: value.TypeLabel, In: in, Out: out, AvailableMin: available, Hours: DayHours(nil, value.Place.Hours, day)})
	}
	return candidates, nil
}

// ValidateTitle は旅程名（1〜100文字）を確認する。POST /itineraries・PATCH /itineraries/:id・
// POST /itineraries/:id/copy で同じ上限を使い、作成した旅程名でコピーや変更が失敗しないようにする。
func ValidateTitle(title string) error {
	if !Text(title, 1, MaxTitleLength) {
		return Invalid("title は1〜100文字で指定してください")
	}
	return nil
}

// Copy は旅程を date の日にコピーする（F-11）。行き先・優先度・滞在時間・出発と終わりを引き継ぎ、
// 新しい日付の営業時間と時刻表で作り直す。訪問順は元の旅程の順を使い、入りきらない行き先は dropped に入る。
func (a *App) Copy(ctx context.Context, old Itinerary, date, title string) (Itinerary, error) {
	if _, err := time.ParseInLocation("2006-01-02", date, JST); err != nil {
		return Itinerary{}, Invalid("date は YYYY-MM-DD で指定してください")
	}
	if title == "" {
		title = old.Title
	}
	departAt, err := clock(old.Start.DepartAt)
	if err != nil {
		return Itinerary{}, err
	}
	start := old.Start
	start.DepartAt = departAt
	end := old.End
	end.ArriveAt = ""
	visits := []Visit{}
	for _, item := range old.Items {
		visits = append(visits, Visit{PlaceID: item.PlaceID, Priority: item.Priority, StayMin: item.StayMin})
	}
	input := PlanInput{Title: title, Date: date, Start: start, End: end, Places: visits}
	if _, err := At(date, start.DepartAt); err != nil {
		return Itinerary{}, Invalid("date が不正です")
	}
	places, err := a.Places(ctx, visits)
	if err != nil {
		return Itinerary{}, err
	}
	next, err := a.Build(ctx, input, places, visits, BuildOptions{})
	if err != nil {
		return Itinerary{}, err
	}
	// 元の旅程で入りきらなかった行き先は、コピーでも入らなかったものとして残す。
	present := map[string]bool{}
	for _, item := range next.Items {
		present[item.PlaceID] = true
	}
	for _, item := range next.Dropped {
		present[item.PlaceID] = true
	}
	for _, item := range old.Dropped {
		if !present[item.PlaceID] {
			next.Dropped = append(next.Dropped, item)
		}
	}
	return next, nil
}
