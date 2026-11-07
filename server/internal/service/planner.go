package service

import (
	"context"
	"crypto/rand"
	"encoding/json"
	"sort"
	"time"

	"golang.org/x/sync/errgroup"
)

var JST = time.FixedZone("Asia/Tokyo", 9*60*60)

func At(date, clock string) (time.Time, error) {
	value, err := time.ParseInLocation("2006-01-02 15:04", date+" "+clock, JST)
	if err != nil || value.Format("2006-01-02 15:04") != date+" "+clock {
		return time.Time{}, Invalid("日時の形式が不正です")
	}
	return value, nil
}

func ValidateVisits(visits []Visit) error {
	if len(visits) < 1 || len(visits) > 10 {
		return Invalid("places は1〜10件で指定してください")
	}
	seen := map[string]bool{}
	for _, visit := range visits {
		if !ValidID(visit.PlaceID) || seen[visit.PlaceID] {
			return Invalid("施設IDが不正、または重複しています")
		}
		seen[visit.PlaceID] = true
		if visit.Priority != "must" && visit.Priority != "want" && visit.Priority != "optional" {
			return Invalid("priority が不正です")
		}
		if visit.StayMin < 10 || visit.StayMin > 480 {
			return Invalid("stayMin は10〜480分で指定してください")
		}
	}
	return nil
}

// MaxItineraries は1人が保存できる旅程の件数。
const MaxItineraries = 20

// MaxTitleLength は旅程名の最大文字数。作成・名前の変更・コピーで共通。
const MaxTitleLength = 100

func validEndpoint(id *string, location *Point, name, label string) error {
	if id != nil {
		if !ValidID(*id) || location != nil {
			return Invalid(label + " は placeId か location と name のどちらか一方で指定してください")
		}
		return nil
	}
	if location == nil || !ValidPoint(*location) || !Text(name, 1, 100) {
		return Invalid(label + " は placeId か location と name のどちらか一方で指定してください")
	}
	return nil
}

// ValidateStart は出発地の指定と出発時刻（HH:mm）を確認する。
func ValidateStart(date string, start Start) (time.Time, error) {
	if err := validEndpoint(start.PlaceID, start.Location, start.Name, "start"); err != nil {
		return time.Time{}, err
	}
	value, err := At(date, start.DepartAt)
	if err != nil {
		return time.Time{}, Invalid("date / start.departAt が不正です")
	}
	return value, nil
}

// ValidateEnd は終わる場所の指定と着きたい時刻（HH:mm）を確認する。
func ValidateEnd(date string, end End) (time.Time, error) {
	if err := validEndpoint(end.PlaceID, end.Location, end.Name, "end"); err != nil {
		return time.Time{}, err
	}
	value, err := At(date, end.ArriveBy)
	if err != nil {
		return time.Time{}, Invalid("end.arriveBy が不正です")
	}
	return value, nil
}

func ValidatePlan(input PlanInput) error {
	if err := ValidateTitle(input.Title); err != nil {
		return err
	}
	start, err := ValidateStart(input.Date, input.Start)
	if err != nil {
		return err
	}
	end, err := ValidateEnd(input.Date, input.End)
	if err != nil {
		return err
	}
	if !end.After(start) {
		return Invalid("end.arriveBy は出発後の同日内の時刻を指定してください")
	}
	return ValidateVisits(input.Places)
}

func OrderedVisits(visits []Visit, ids []string) ([]Visit, error) {
	if len(ids) != len(visits) {
		return nil, Upstream()
	}
	byID := map[string]Visit{}
	for _, visit := range visits {
		byID[visit.PlaceID] = visit
	}
	ordered := make([]Visit, 0, len(ids))
	for _, id := range ids {
		visit, ok := byID[id]
		if !ok {
			return nil, Upstream()
		}
		ordered = append(ordered, visit)
		delete(byID, id)
	}
	return ordered, nil
}

func OpenAt(hours *Hours, arrival time.Time, stay int) (time.Time, *OpeningHours, bool) {
	if hours == nil {
		return arrival, nil, true
	}
	day := time.Date(arrival.Year(), arrival.Month(), arrival.Day(), 0, 0, 0, 0, JST)
	sunday := day.AddDate(0, 0, -int(day.Weekday()))
	var best time.Time
	var window *OpeningHours
	for _, period := range hours.Periods {
		if period.Open.Day < 0 || period.Open.Day > 6 || period.Open.Hour < 0 || period.Open.Hour > 23 || period.Open.Minute < 0 || period.Open.Minute > 59 {
			continue
		}
		if period.Close == nil {
			return arrival, &OpeningHours{OpensAt: "00:00", ClosesAt: "24:00"}, true
		}
		close := *period.Close
		if close.Day < 0 || close.Day > 6 || close.Hour < 0 || close.Hour > 23 || close.Minute < 0 || close.Minute > 59 {
			continue
		}
		open := sunday.AddDate(0, 0, period.Open.Day).Add(time.Duration(period.Open.Hour*60+period.Open.Minute) * time.Minute)
		end := sunday.AddDate(0, 0, close.Day).Add(time.Duration(close.Hour*60+close.Minute) * time.Minute)
		if !end.After(open) {
			end = end.AddDate(0, 0, 7)
		}
		for _, offset := range []int{-7, 0, 7} {
			begin := open.AddDate(0, 0, offset)
			finish := end.AddDate(0, 0, offset)
			start := arrival
			if start.Before(begin) {
				start = begin
			}
			if start.In(JST).Format("2006-01-02") != arrival.In(JST).Format("2006-01-02") || start.Add(time.Duration(stay)*time.Minute).After(finish) {
				continue
			}
			if best.IsZero() || start.Before(best) {
				best = start
				window = &OpeningHours{OpensAt: begin.Format("15:04"), ClosesAt: finish.Format("15:04")}
			}
		}
	}
	return best, window, !best.IsZero()
}

// Places は行き先と、placeId で指定された出発地・終わる場所の施設情報を取得する。
func (a *App) Places(ctx context.Context, visits []Visit, endpoints ...*string) (map[string]Place, error) {
	ids := []string{}
	seen := map[string]bool{}
	add := func(id string) {
		if id != "" && !seen[id] {
			seen[id] = true
			ids = append(ids, id)
		}
	}
	for _, id := range endpoints {
		if id != nil {
			add(*id)
		}
	}
	for _, visit := range visits {
		add(visit.PlaceID)
	}
	values := make([]Place, len(ids))
	group, ctx := errgroup.WithContext(ctx)
	group.SetLimit(4)
	for i, id := range ids {
		group.Go(func() error { value, err := a.Maps.Details(ctx, id); values[i] = value; return err })
	}
	if err := group.Wait(); err != nil {
		return nil, err
	}
	places := map[string]Place{}
	for _, value := range values {
		places[value.PlaceID] = value
	}
	return places, nil
}

// fillEndpoints は placeId で指定された出発地・終わる場所に名前と座標を入れる。
func fillEndpoints(input *PlanInput, places map[string]Place) {
	if id := input.Start.PlaceID; id != nil {
		place := places[*id]
		location := place.Location
		input.Start.Name, input.Start.Location = place.Name, &location
	}
	if id := input.End.PlaceID; id != nil {
		place := places[*id]
		location := place.Location
		input.End.Name, input.End.Location = place.Name, &location
	}
}

func (a *App) Plan(ctx context.Context, input PlanInput) (Itinerary, error) {
	if err := ValidatePlan(input); err != nil {
		return Itinerary{}, err
	}
	places, err := a.Places(ctx, input.Places, input.Start.PlaceID, input.End.PlaceID)
	if err != nil {
		return Itinerary{}, err
	}
	fillEndpoints(&input, places)
	data, _ := json.Marshal(map[string]any{"request": input, "verifiedPlaces": places})
	var output struct {
		PlaceIDs []string `json:"placeIds"`
	}
	err = a.AI.Generate(ctx, "次の行き先をすべて1回ずつ訪問する順番を提案してください。必須の施設の成立を優先し、移動を抑えてください。最後に終わる場所（request.end）へ移動することも考慮してください。placeIds に入力の全施設IDを重複なく入れてください。\n"+string(data), ObjectSchema(map[string]any{"placeIds": StringArraySchema()}), &output)
	if err != nil {
		return Itinerary{}, err
	}
	ordered, err := OrderedVisits(input.Places, output.PlaceIDs)
	if err != nil {
		return Itinerary{}, err
	}
	return a.Build(ctx, input, places, ordered, BuildOptions{})
}

func infeasible(ids ...string) *Error {
	err := Fail(422, "MUST_ITEMS_INFEASIBLE", "営業時間や終わる場所に着きたい時刻までに、必須の予定が入りません")
	err.Details["placeIds"] = ids
	return err
}

func endInfeasible() *Error {
	return Fail(422, "END_INFEASIBLE", "行き先を外しても、終わる場所に着きたい時刻までに着けません")
}

func ItineraryLimit() *Error {
	err := Fail(422, "ITINERARY_LIMIT", "保存できる旅程の上限（1人20件）を超えます")
	err.Details["limit"] = MaxItineraries
	return err
}

func summarize(value *Itinerary) {
	value.Summary = Summary{EndAt: value.Start.DepartAt}
	for _, leg := range value.Legs {
		value.Summary.MoveMin += leg.DurationMin
	}
	for _, item := range value.Items {
		value.Summary.EndAt = item.EndAt
		if item.Price.Amount != nil {
			value.Summary.PriceTotal.Amount += *item.Price.Amount
		}
		if item.Price.Kind != "fixed" {
			value.Summary.PriceTotal.HasEstimate = true
		}
	}
	if value.End.ArriveAt != "" {
		value.Summary.EndAt = value.End.ArriveAt
	}
}

func (a *App) route(ctx context.Context, cache map[string]Leg, from, to Waypoint, depart time.Time) (Leg, error) {
	key := from.Key() + "/" + to.Key() + "/" + depart.Format(time.RFC3339)
	if leg, ok := cache[key]; ok {
		return leg, nil
	}
	leg, err := a.Maps.Route(ctx, from, to, depart)
	if err != nil {
		return Leg{}, err
	}
	if cache != nil {
		cache[key] = leg
	}
	return leg, nil
}

// schedule は訪問順どおりに時刻を計算する。終わる場所への移動も Leg（toItemId: "end"）として加え、
// lateEnd が false のときは end.arriveBy までに着けなければ END_INFEASIBLE を返す。
func (a *App) schedule(ctx context.Context, input PlanInput, places map[string]Place, visits []Visit, cache map[string]Leg, lateEnd bool) (Itinerary, error) {
	depart, err := At(input.Date, input.Start.DepartAt)
	if err != nil {
		return Itinerary{}, Invalid("出発時刻が不正です")
	}
	arriveBy, err := At(input.Date, input.End.ArriveBy)
	if err != nil {
		return Itinerary{}, Invalid("終わる場所に着きたい時刻が不正です")
	}
	day, _ := time.ParseInLocation("2006-01-02", input.Date, JST)
	value := Itinerary{Title: input.Title, Date: input.Date, Start: input.Start, End: input.End, Items: []Item{}, Legs: []Leg{}, Dropped: []Dropped{}, ExpiresAt: day.AddDate(0, 0, 30).Format(time.RFC3339)}
	value.Start.DepartAt = depart.Format(time.RFC3339)
	from := input.Start.Waypoint()
	fromID := "start"
	for _, visit := range visits {
		p, ok := places[visit.PlaceID]
		if !ok {
			return Itinerary{}, Upstream()
		}
		leg, err := a.route(ctx, cache, from, Waypoint{PlaceID: p.PlaceID}, depart)
		if err != nil {
			return Itinerary{}, err
		}
		arrival, err := time.Parse(time.RFC3339, leg.ArriveAt)
		if err != nil {
			return Itinerary{}, Upstream()
		}
		start, hours, ok := OpenAt(p.Hours, arrival, visit.StayMin)
		if !ok || start.Add(time.Duration(visit.StayMin)*time.Minute).After(arriveBy) {
			return Itinerary{}, infeasible(visit.PlaceID)
		}
		item := Item{
			ItemID: "it_" + rand.Text(), PlaceID: p.PlaceID, Name: p.Name,
			Priority: visit.Priority, StayMin: visit.StayMin,
			StartAt: start.Format(time.RFC3339),
			EndAt:   start.Add(time.Duration(visit.StayMin) * time.Minute).Format(time.RFC3339),
			Price:   Price{Kind: "unknown"}, OpeningHours: hours, Status: "upcoming",
		}
		leg.FromItemID = fromID
		leg.ToItemID = item.ItemID
		value.Items = append(value.Items, item)
		value.Legs = append(value.Legs, leg)
		from = Waypoint{PlaceID: p.PlaceID}
		fromID = item.ItemID
		depart = start.Add(time.Duration(visit.StayMin) * time.Minute)
	}
	leg, err := a.route(ctx, cache, from, input.End.Waypoint(), depart)
	if err != nil {
		return Itinerary{}, err
	}
	arrival, err := time.Parse(time.RFC3339, leg.ArriveAt)
	if err != nil {
		return Itinerary{}, Upstream()
	}
	if arrival.After(arriveBy) && !lateEnd {
		return Itinerary{}, endInfeasible()
	}
	leg.FromItemID = fromID
	leg.ToItemID = "end"
	value.Legs = append(value.Legs, leg)
	value.End.ArriveAt = arrival.Format(time.RFC3339)
	summarize(&value)
	return value, nil
}

// BuildOptions は組み立て時の扱い。DropMust は必須の予定も外せる（組み直し用）、
// LateEnd は終わる場所に間に合わない場合も行き先をすべて外した旅程を返す（組み直し用）。
type BuildOptions struct {
	DropMust bool
	LateEnd  bool
}

func errorCode(err error) string {
	if err == nil {
		return ""
	}
	return APIError(err).Code
}

func (a *App) Build(ctx context.Context, input PlanInput, places map[string]Place, order []Visit, options BuildOptions) (Itinerary, error) {
	cache := map[string]Leg{}
	selected := []Visit{}
	remaining := []Visit{}
	musts := []Visit{}
	dropped := []Dropped{}
	for _, visit := range order {
		if visit.Priority == "must" {
			musts = append(musts, visit)
		} else {
			remaining = append(remaining, visit)
		}
	}
	selected = append(selected, musts...)
	value, err := a.schedule(ctx, input, places, selected, cache, false)
	if err != nil {
		if APIError(err).Status != 422 {
			return Itinerary{}, err
		}
		base, baseErr := a.schedule(ctx, input, places, nil, cache, false)
		switch {
		case baseErr == nil && options.DropMust:
			selected = []Visit{}
			remaining = append(musts, remaining...)
			value = base
		case baseErr == nil && errorCode(err) == "END_INFEASIBLE":
			ids := []string{}
			for _, visit := range musts {
				ids = append(ids, visit.PlaceID)
			}
			return Itinerary{}, infeasible(ids...)
		case baseErr == nil:
			return Itinerary{}, err
		case errorCode(baseErr) == "END_INFEASIBLE" && options.LateEnd:
			value, err = a.schedule(ctx, input, places, nil, cache, true)
			if err != nil {
				return Itinerary{}, err
			}
			for _, visit := range order {
				dropped = append(dropped, Dropped{PlaceID: visit.PlaceID, Name: places[visit.PlaceID].Name, Reason: "終わる場所に着きたい時刻までに入りません"})
			}
			value.Dropped = dropped
			return value, nil
		default:
			return Itinerary{}, baseErr
		}
	}
	rank := map[string]int{}
	for i, visit := range order {
		rank[visit.PlaceID] = i
	}
	sort.SliceStable(remaining, func(i, j int) bool {
		priority := map[string]int{"must": 0, "want": 1, "optional": 2}
		return priority[remaining[i].Priority] < priority[remaining[j].Priority]
	})
	for _, visit := range remaining {
		trial := append(append([]Visit{}, selected...), visit)
		sort.SliceStable(trial, func(i, j int) bool { return rank[trial[i].PlaceID] < rank[trial[j].PlaceID] })
		candidate, err := a.schedule(ctx, input, places, trial, cache, false)
		if err != nil {
			if APIError(err).Status != 422 {
				return Itinerary{}, err
			}
			dropped = append(dropped, Dropped{PlaceID: visit.PlaceID, Name: places[visit.PlaceID].Name, Reason: "営業時間や終わる場所に着きたい時刻までに入りません"})
			continue
		}
		selected = trial
		value = candidate
	}
	value.Dropped = dropped
	return value, nil
}

func ReuseItems(old Itinerary, value *Itinerary) {
	oldItems := map[string]Item{}
	for _, item := range old.Items {
		oldItems[item.PlaceID] = item
	}
	ids := map[string]string{}
	for i, item := range value.Items {
		if oldItem, ok := oldItems[item.PlaceID]; ok {
			ids[item.ItemID] = oldItem.ItemID
			value.Items[i].ItemID = oldItem.ItemID
			value.Items[i].Status = oldItem.Status
			value.Items[i].Price = oldItem.Price
		}
	}
	for i, leg := range value.Legs {
		if id, ok := ids[leg.FromItemID]; ok {
			value.Legs[i].FromItemID = id
		}
		if id, ok := ids[leg.ToItemID]; ok {
			value.Legs[i].ToItemID = id
		}
	}
	summarize(value)
}
