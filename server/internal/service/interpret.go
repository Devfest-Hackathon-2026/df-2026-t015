package service

import (
	"context"
	"strings"

	"golang.org/x/sync/errgroup"
)

// Interpreted は POST /places/interpret の候補1件。
type Interpreted struct {
	Place  Place  `json:"place"`
	Reason string `json:"reason"`
}

// Interpret は自由文の希望を、実在する施設の候補（最大5件）にする（F-01）。
//  1. Gemini が希望を Places で探せる検索語（最大5件）に分ける。検索語だけを返させ、説明文は出させない。
//  2. 検索語ごとに Places Text Search を呼び、実在する施設だけを候補にする（重複は除く）。
//  3. Gemini が候補の placeId（enum で候補に限定）から希望に合うものを最大5件選び、理由をつける。
//  4. 応答は {place, reason} の配列だけにする。3 が失敗したら、検索語ごとの先頭の施設と 1 の理由で返す。
func (a *App) Interpret(ctx context.Context, text string, near *Point) ([]Interpreted, error) {
	var plan struct {
		Queries []struct {
			Query  string `json:"query"`
			Intent string `json:"intent"`
		} `json:"queries"`
	}
	schema := ObjectSchema(map[string]any{
		"queries": map[string]any{
			"type": "array", "minItems": 1, "maxItems": 5,
			"items": ObjectSchema(map[string]any{
				"query":  map[string]any{"type": "string"},
				"intent": map[string]any{"type": "string"},
			}),
		},
	})
	prompt := Prompt{
		Task: "旅行の希望文（request）を、Google マップの施設検索で使う検索語に分けてください。",
		Rules: []string{
			"query は施設の種類や名前を表す短い日本語（例: 海が見えるカフェ、寺院、日帰り温泉）。地名が希望文にあれば含める。",
			"希望文に複数の希望があれば別々の query にする。同じ意味の query は1つにまとめる。",
			"intent は、その query で探す理由を希望文の言葉で短く書く。",
		},
		Data:        map[string]any{"request": text},
		Temperature: 0.2,
	}
	if err := a.AI.Ask(ctx, prompt, schema, &plan); err != nil {
		return nil, err
	}
	type query struct{ text, intent string }
	queries := []query{}
	seenQuery := map[string]bool{}
	for _, q := range plan.Queries {
		value := strings.TrimSpace(q.Query)
		key := strings.ToLower(strings.Join(strings.Fields(value), ""))
		if !Text(value, 1, 200) || seenQuery[key] || len(queries) >= 5 {
			continue
		}
		seenQuery[key] = true
		queries = append(queries, query{text: value, intent: strings.TrimSpace(q.Intent)})
	}
	if len(queries) == 0 {
		return nil, Upstream()
	}
	results := make([][]Place, len(queries))
	group, groupCtx := errgroup.WithContext(ctx)
	group.SetLimit(3)
	for i, q := range queries {
		group.Go(func() error {
			places, err := a.Maps.Search(groupCtx, q.text, near)
			results[i] = places
			return err
		})
	}
	if err := group.Wait(); err != nil {
		return nil, err
	}
	byID := map[string]Place{}
	fallback := []Interpreted{}
	type candidateFact struct {
		PlaceID string `json:"placeId"`
		Name    string `json:"name"`
		Address string `json:"address"`
		Query   string `json:"foundBy"`
	}
	facts := []candidateFact{}
	ids := []string{}
	for i, places := range results {
		usedForFallback := false
		for _, place := range places {
			if _, exists := byID[place.PlaceID]; exists {
				continue
			}
			byID[place.PlaceID] = place
			ids = append(ids, place.PlaceID)
			facts = append(facts, candidateFact{PlaceID: place.PlaceID, Name: place.Name, Address: place.Address, Query: queries[i].text})
			if !usedForFallback && len(fallback) < 5 {
				reason := queries[i].intent
				if !Text(reason, 1, 500) {
					reason = queries[i].text + "に合う施設です"
				}
				fallback = append(fallback, Interpreted{Place: place, Reason: reason})
				usedForFallback = true
			}
		}
	}
	if len(ids) == 0 {
		return []Interpreted{}, nil
	}
	var selection struct {
		Candidates []struct {
			PlaceID string `json:"placeId"`
			Reason  string `json:"reason"`
		} `json:"candidates"`
	}
	schema = ObjectSchema(map[string]any{
		"candidates": map[string]any{
			"type": "array", "minItems": 1, "maxItems": 5,
			"items": ObjectSchema(map[string]any{
				"placeId": map[string]any{"type": "string", "enum": ids},
				"reason":  map[string]any{"type": "string"},
			}),
		},
	})
	prompt = Prompt{
		Task: "検索で見つかった実在の施設（places）から、旅行の希望（request）に合うものを最大5件選んでください。",
		Rules: []string{
			"希望に合う順に並べる。希望が複数あるときは、それぞれの希望から少なくとも1件ずつ選ぶ。",
			"reason は、その施設が希望のどこに合うかを30文字程度で書く。施設名・住所・foundBy（見つけた検索語）から言えることだけを書く。",
		},
		Data:        map[string]any{"request": text, "places": facts},
		Temperature: 0.2,
	}
	if err := a.AI.Ask(ctx, prompt, schema, &selection); err != nil {
		return fallback, nil
	}
	selected := []Interpreted{}
	seen := map[string]bool{}
	for _, c := range selection.Candidates {
		place, ok := byID[c.PlaceID]
		reason := strings.TrimSpace(c.Reason)
		if !ok || seen[c.PlaceID] || !Text(reason, 1, 500) || len(selected) >= 5 {
			continue
		}
		seen[c.PlaceID] = true
		selected = append(selected, Interpreted{Place: place, Reason: reason})
	}
	if len(selected) == 0 {
		return fallback, nil
	}
	return selected, nil
}
