package service

import (
	"context"
	"math"
	"strings"
	"time"
)

// 訪問順を決める流れ:
//  1. サーバーが直線距離で「基準の順番」を作る（新規作成は最近傍法＋2-opt、編集は今の順番に最小コストで挿入）。
//  2. Gemini に、施設情報・距離表・基準の順番を渡し、施設IDの配列（enum で入力の施設IDに限定）だけを返させる。
//  3. AI の順番を正規化する（未知・重複を除き、抜けた施設は最小コスト挿入で補う）。
//  4. 両方の順番で実際の移動時間・営業時間を使って旅程を組み、点数の良い方を採用する。
// AI の呼び出しに失敗しても、基準の順番で旅程を返せる。

// orderPoint は順番を考えるための地点。
type orderPoint struct {
	Visit    Visit
	Location Point
}

func pathCost(start Point, end *Point, points []orderPoint) float64 {
	total := 0.0
	previous := start
	for _, p := range points {
		total += distance(previous, p.Location)
		previous = p.Location
	}
	if end != nil {
		total += distance(previous, *end)
	}
	return total
}

// NearestNeighborOrder は must を先に、優先度ごとに出発地から近い順で並べたあと、2-opt で交差を減らす。
func NearestNeighborOrder(start Point, end *Point, visits []Visit, places map[string]Place) []Visit {
	points := []orderPoint{}
	for _, visit := range visits {
		points = append(points, orderPoint{Visit: visit, Location: places[visit.PlaceID].Location})
	}
	ordered := []orderPoint{}
	used := make([]bool, len(points))
	current := start
	for range points {
		best := -1
		for i, p := range points {
			if used[i] {
				continue
			}
			if best < 0 || distance(current, p.Location) < distance(current, points[best].Location) {
				best = i
			}
		}
		used[best] = true
		ordered = append(ordered, points[best])
		current = points[best].Location
	}
	ordered = twoOpt(start, end, ordered)
	result := make([]Visit, len(ordered))
	for i, p := range ordered {
		result[i] = p.Visit
	}
	return result
}

func twoOpt(start Point, end *Point, points []orderPoint) []orderPoint {
	best := append([]orderPoint{}, points...)
	cost := pathCost(start, end, best)
	for improved := true; improved; {
		improved = false
		for i := 0; i < len(best)-1; i++ {
			for j := i + 1; j < len(best); j++ {
				trial := append([]orderPoint{}, best...)
				for a, b := i, j; a < b; a, b = a+1, b-1 {
					trial[a], trial[b] = trial[b], trial[a]
				}
				if c := pathCost(start, end, trial); c+1 < cost {
					best, cost, improved = trial, c, true
				}
			}
		}
	}
	return best
}

// InsertCheapest は base の順番を保ったまま、added を直線距離の増え方が最も小さい位置に1つずつ挿入する。
func InsertCheapest(start Point, end *Point, base, added []Visit, places map[string]Place) []Visit {
	points := []orderPoint{}
	for _, visit := range base {
		points = append(points, orderPoint{Visit: visit, Location: places[visit.PlaceID].Location})
	}
	for _, visit := range added {
		p := orderPoint{Visit: visit, Location: places[visit.PlaceID].Location}
		bestAt, bestCost := 0, math.Inf(1)
		for at := 0; at <= len(points); at++ {
			trial := append(append(append([]orderPoint{}, points[:at]...), p), points[at:]...)
			if c := pathCost(start, end, trial); c < bestCost {
				bestAt, bestCost = at, c
			}
		}
		points = append(append(append([]orderPoint{}, points[:bestAt]...), p), points[bestAt:]...)
	}
	result := make([]Visit, len(points))
	for i, p := range points {
		result[i] = p.Visit
	}
	return result
}

// NormalizeOrder は AI が返した施設IDの並びを、入力の visits に合わせて整える。
// 未知のIDと重複は捨て、抜けた施設は最小コスト挿入で補う。使えるIDが1つもなければ ok=false。
func NormalizeOrder(ids []string, visits []Visit, start Point, end *Point, places map[string]Place) ([]Visit, bool) {
	byID := map[string]Visit{}
	for _, visit := range visits {
		byID[visit.PlaceID] = visit
	}
	ordered := []Visit{}
	seen := map[string]bool{}
	for _, id := range ids {
		visit, ok := byID[id]
		if !ok || seen[id] {
			continue
		}
		seen[id] = true
		ordered = append(ordered, visit)
	}
	if len(ordered) == 0 && len(visits) > 0 {
		return nil, false
	}
	missing := []Visit{}
	for _, visit := range visits {
		if !seen[visit.PlaceID] {
			missing = append(missing, visit)
		}
	}
	return InsertCheapest(start, end, ordered, missing, places), true
}

func signature(visits []Visit) string {
	ids := make([]string, len(visits))
	for i, visit := range visits {
		ids[i] = visit.PlaceID
	}
	return strings.Join(ids, "/")
}

// arrangeRequest は arrange の入力。
type arrangeRequest struct {
	Input  PlanInput
	Places map[string]Place
	// Base はサーバーが作った基準の順番。AI の順番と比べ、同点なら Base を採る。
	Base []Visit
	// Prompt は AI に順番を尋ねる指示。Data には施設情報などを入れる。
	Prompt Prompt
}

// arrange は基準の順番と AI の順番で旅程を組み、良い方を返す。
func (a *App) arrange(ctx context.Context, req arrangeRequest) (Itinerary, error) {
	visits := req.Input.Places
	cache := map[string]Leg{}
	options := BuildOptions{Cache: cache}
	priority := map[string]string{}
	for _, visit := range visits {
		priority[visit.PlaceID] = visit.Priority
	}
	best, bestErr := a.Build(ctx, req.Input, req.Places, req.Base, options)
	if len(visits) < 2 || a.AI == nil {
		return best, bestErr
	}
	ids := make([]string, len(visits))
	for i, visit := range visits {
		ids[i] = visit.PlaceID
	}
	var output struct {
		PlaceIDs []string `json:"placeIds"`
	}
	schema := ObjectSchema(map[string]any{"placeIds": IDArraySchema(ids, len(ids), len(ids))})
	if err := a.AI.Ask(ctx, req.Prompt, schema, &output); err != nil {
		// AI が使えなくても、基準の順番で組めていればそれを返す。
		if bestErr == nil {
			return best, nil
		}
		return Itinerary{}, err
	}
	start := req.Input.Start.Location
	if start == nil {
		start = &Point{}
	}
	ordered, ok := NormalizeOrder(output.PlaceIDs, visits, *start, req.Input.End.Location, req.Places)
	if !ok || signature(ordered) == signature(req.Base) {
		return best, bestErr
	}
	candidate, err := a.Build(ctx, req.Input, req.Places, ordered, options)
	switch {
	case err != nil && bestErr != nil:
		return Itinerary{}, bestErr
	case err != nil:
		return best, nil
	case bestErr != nil:
		return candidate, nil
	}
	if scoreWith(candidate, priority) < scoreWith(best, priority) {
		return candidate, nil
	}
	return best, nil
}

// scoreWith は旅程の良さ（小さいほど良い）。外した行き先を優先度で重く数え、次に移動時間、最後に到着時刻を比べる。
func scoreWith(value Itinerary, priority map[string]string) float64 {
	weight := map[string]float64{"must": 100000, "want": 1000, "optional": 100}
	score := 0.0
	for _, item := range value.Dropped {
		score += weight[priority[item.PlaceID]]
	}
	score += float64(value.Summary.MoveMin)
	if end, err := time.Parse(time.RFC3339, value.Summary.EndAt); err == nil {
		score += float64(end.Hour()*60+end.Minute()) / 1000
	}
	return score
}

// distanceTable は施設間の直線距離（km、小数1桁）。AI が移動を見積もる材料にする。
func distanceTable(points map[string]Point) map[string]map[string]float64 {
	table := map[string]map[string]float64{}
	for a, pa := range points {
		table[a] = map[string]float64{}
		for b, pb := range points {
			if a != b {
				table[a][b] = math.Round(distance(pa, pb)/100) / 10
			}
		}
	}
	return table
}
