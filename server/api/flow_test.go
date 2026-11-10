package api

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"reflect"
	"strconv"
	"strings"
	"testing"
	"time"

	"github.com/create-alt/gen-TLE/server/internal/service"
)

type flowStore struct {
	service.Store
	trip     service.Itinerary
	proposal service.Replan
	count    int
}

func (s *flowStore) Allow(context.Context, string) error { return nil }
func (s *flowStore) Create(ctx context.Context, uid string, value *service.Itinerary) error {
	value.ID = "trip"
	value.Version = 1
	s.trip = *value
	return nil
}
func (s *flowStore) Get(ctx context.Context, uid, id string) (service.Itinerary, error) {
	if uid != "owner" || id != s.trip.ID {
		return service.Itinerary{}, service.NotFound()
	}
	return s.trip, nil
}
func (s *flowStore) List(context.Context, string, int, string) (service.ItineraryPage, error) {
	return service.ItineraryPage{Itineraries: []service.ItineraryEntry{{ID: s.trip.ID}}}, nil
}
func (s *flowStore) Count(context.Context, string) (int, error) { return s.count, nil }
func (s *flowStore) Delete(ctx context.Context, uid, id string, version int) error {
	if id != s.trip.ID {
		return service.NotFound()
	}
	if version != s.trip.Version {
		return service.Conflict()
	}
	s.trip = service.Itinerary{}
	return nil
}
func (s *flowStore) Update(ctx context.Context, uid, id string, version int, value *service.Itinerary) error {
	if version != s.trip.Version {
		return service.Conflict()
	}
	value.ID = id
	value.Version = version + 1
	s.trip = *value
	return nil
}
func (s *flowStore) SaveReplan(ctx context.Context, uid string, value *service.Replan) error {
	value.ReplanID = "rp"
	s.proposal = *value
	return nil
}
func (s *flowStore) GetReplan(ctx context.Context, uid, id, rid string) (service.Replan, error) {
	return s.proposal, nil
}
func (s *flowStore) ClaimExplanation(ctx context.Context, uid, id, rid, option string) (service.Explanation, bool, error) {
	result := s.proposal.Explanations[option]
	return result, result.Status == "pending", nil
}
func (s *flowStore) FinishExplanation(ctx context.Context, uid, id, rid, option, lease string, value service.Explanation) error {
	s.proposal.Explanations[option] = value
	return nil
}
func (s *flowStore) Accept(ctx context.Context, uid, id, rid, option string, version int) (service.Itinerary, error) {
	if version != s.trip.Version {
		return service.Itinerary{}, service.Conflict()
	}
	for _, proposal := range s.proposal.Options {
		if proposal.OptionID == option {
			next := proposal.Candidate
			next.ID = id
			next.Version = version + 1
			s.trip = next
			return next, nil
		}
	}
	return service.Itinerary{}, service.Invalid("optionId")
}

type flowTransport struct{}

// schemaNode は Gemini に送られた JSON スキーマの一部。テストの偽の Gemini が enum から答えを作るのに使う。
type schemaNode struct {
	Properties map[string]*schemaNode `json:"properties"`
	Items      *schemaNode            `json:"items"`
	Enum       []string               `json:"enum"`
}

func (flowTransport) RoundTrip(r *http.Request) (*http.Response, error) {
	var data any
	switch {
	case strings.HasSuffix(r.URL.Path, "places:autocomplete"):
		data = map[string]any{"suggestions": []any{map[string]any{"placePrediction": map[string]any{"placeId": "p1", "structuredFormat": map[string]any{"mainText": map[string]string{"text": "公園"}, "secondaryText": map[string]string{"text": "東京都"}}}}}}
	case strings.HasSuffix(r.URL.Path, "places:searchNearby"):
		data = map[string]any{"places": []any{
			map[string]any{"id": "near", "displayName": map[string]string{"text": "山あいの駅"}, "location": map[string]float64{"latitude": 35.001, "longitude": 139}, "primaryTypeDisplayName": map[string]string{"text": "駅"}},
			map[string]any{"id": "far", "displayName": map[string]string{"text": "遠くの駅"}, "location": map[string]float64{"latitude": 36, "longitude": 139}},
		}}
	case strings.HasSuffix(r.URL.Path, "places:searchText"):
		data = map[string]any{"places": []any{map[string]any{"id": "p3", "displayName": map[string]string{"text": "公園3"}, "location": map[string]int{"latitude": 35, "longitude": 139}}}}
	case strings.HasPrefix(r.URL.Path, "/v1/places/"):
		id := strings.TrimPrefix(r.URL.Path, "/v1/places/")
		place := map[string]any{"id": id, "displayName": map[string]string{"text": id}, "location": map[string]int{"latitude": 35, "longitude": 139}}
		if id == "onsen" {
			// 土曜（day 6）だけ 10:00〜21:00 に営業する温泉
			place["primaryTypeDisplayName"] = map[string]string{"text": "温泉"}
			place["priceRange"] = map[string]any{"startPrice": map[string]string{"currencyCode": "JPY", "units": "600"}}
			place["regularOpeningHours"] = map[string]any{"periods": []any{map[string]any{"open": map[string]int{"day": 6, "hour": 10}, "close": map[string]int{"day": 6, "hour": 21}}}}
		}
		data = place
	case strings.Contains(r.URL.Path, "/toolbox/course/condition"):
		data = map[string]any{"ResultSet": map[string]string{"Condition": "rail-bus-walk"}}
	case strings.Contains(r.URL.Path, "/search/course/extreme"):
		depart, err := time.ParseInLocation("200601021504", r.URL.Query().Get("date")+r.URL.Query().Get("time"), service.JST)
		if err != nil {
			return nil, err
		}
		data = map[string]any{"ResultSet": map[string]any{"Course": []any{map[string]any{"Route": map[string]any{"Line": []any{map[string]any{
			"Type": "train", "Name": "鉄道",
			"DepartureState": map[string]any{"Datetime": map[string]string{"text": depart.Format(time.RFC3339), "operation": "today"}},
			"ArrivalState":   map[string]any{"Datetime": map[string]string{"text": depart.Add(10 * time.Minute).Format(time.RFC3339), "operation": "today"}},
		}}}}}}}
	case strings.Contains(r.URL.Path, "generateContent"):
		var request struct {
			Config struct {
				Schema schemaNode `json:"responseJsonSchema"`
			} `json:"generationConfig"`
		}
		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
			return nil, err
		}
		properties := request.Config.Schema.Properties
		var output any
		switch {
		case properties["queries"] != nil:
			output = map[string]any{"queries": []any{map[string]string{"query": "公園", "intent": "散歩したい"}, map[string]string{"query": " 公園 ", "intent": "重複"}}}
		case properties["candidates"] != nil:
			ids := properties["candidates"].Items.Properties["placeId"].Enum
			output = map[string]any{"candidates": []any{map[string]string{"placeId": ids[0], "reason": "散歩に合う公園"}, map[string]string{"placeId": "invented", "reason": "存在しない"}}}
		case properties["placeIds"] != nil:
			output = map[string]any{"placeIds": properties["placeIds"].Items.Enum}
		case properties["options"] != nil:
			ids := properties["options"].Items.Properties["placeIds"].Items.Enum
			output = map[string]any{"options": []any{map[string]any{"label": "同じ順番", "placeIds": ids[:1]}, map[string]any{"label": "近くの施設に置き換え", "placeIds": ids[len(ids)-1:]}}}
		case properties["summary"] != nil:
			reasons := []any{}
			if ids := properties["reasons"].Items.Properties["itemId"].Enum; len(ids) > 0 {
				reasons = append(reasons, map[string]string{"itemId": ids[0], "reason": "40分の遅れに合わせて開始を遅らせました。"})
			}
			output = map[string]any{"summary": "遅延に合わせて時刻を変更しました。", "reasons": reasons}
		case properties["ideas"] != nil:
			result := map[string]any{"ideas": []any{map[string]any{"title": "駅前を散歩する", "description": "次の予定の近くを歩いて過ごします。", "durationMin": 30}, map[string]any{"title": "長すぎる案", "description": "空き時間を超える", "durationMin": 600}}}
			if properties["suggestions"] != nil {
				id := properties["suggestions"].Items.Properties["placeId"].Enum[0]
				result["suggestions"] = []any{map[string]any{"placeId": id, "reason": "近くで散歩できる", "stayMin": 120}}
			}
			output = result
		default:
			return nil, fmt.Errorf("unexpected schema")
		}
		text, _ := json.Marshal(output)
		data = map[string]any{"candidates": []any{map[string]any{"content": map[string]any{"parts": []any{map[string]string{"text": string(text)}}}, "finishReason": "STOP"}}}
	default:
		return nil, fmt.Errorf("unexpected URL %s", r.URL)
	}
	body, _ := json.Marshal(data)
	return &http.Response{StatusCode: 200, Header: make(http.Header), Body: io.NopCloser(strings.NewReader(string(body)))}, nil
}

func TestAPIFlow(t *testing.T) {
	store := &flowStore{}
	client := &http.Client{Transport: flowTransport{}}
	app := &service.App{Store: store, Verify: func(context.Context, string) (string, error) { return "owner", nil }, Maps: &service.Maps{HTTP: client, Transit: &service.Transit{Key: "test", HTTP: client}}, AI: &service.Gemini{HTTP: client, Model: "test"}}
	handler := New(app)
	call := func(method, path, body, version string, status int, output any) {
		t.Helper()
		r := httptest.NewRequest(method, path, strings.NewReader(body))
		r.Header.Set("Content-Type", "application/json")
		r.Header.Set("Authorization", "Bearer test")
		if version != "" {
			r.Header.Set("If-Match", version)
		}
		w := httptest.NewRecorder()
		handler.ServeHTTP(w, r)
		if w.Code != status {
			t.Fatalf("%s %s: %d %s", method, path, w.Code, w.Body.String())
		}
		if output != nil {
			if err := json.Unmarshal(w.Body.Bytes(), output); err != nil {
				t.Fatal(err)
			}
		}
	}
	call("GET", "/places/autocomplete?q=公", "", "", 200, nil)
	var interpreted struct {
		Candidates []service.Interpreted `json:"candidates"`
	}
	call("POST", "/places/interpret", `{"text":"公園を散歩したい"}`, "", 200, &interpreted)
	if len(interpreted.Candidates) != 1 || interpreted.Candidates[0].Place.PlaceID != "p3" || interpreted.Candidates[0].Reason != "散歩に合う公園" {
		t.Fatalf("%+v", interpreted)
	}
	var trip service.Itinerary
	// 地図で選んだ施設ではない地点も出発地・終わる場所にできる。
	var mapTrip service.Itinerary
	call("POST", "/itineraries", `{"title":"旅","date":"2026-11-14","start":{"placeId":null,"location":{"lat":35,"lng":139},"name":"駅前広場","departAt":"09:00"},"end":{"location":{"lat":35,"lng":139},"name":"駅前広場","arriveBy":"17:00"},"places":[{"placeId":"p1","priority":"must","stayMin":60}]}`, "", 201, &mapTrip)
	if mapTrip.Start.PlaceID != nil || mapTrip.Start.Name != "駅前広場" || mapTrip.End.Location == nil {
		t.Fatalf("%+v", mapTrip)
	}
	call("POST", "/itineraries", `{"title":"旅","date":"2026-11-14","start":{"placeId":"start","departAt":"09:00"},"end":{"placeId":"start","arriveBy":"09:05"},"places":[{"placeId":"p1","priority":"must","stayMin":60}]}`, "", 422, nil)
	create := `{"title":"旅","date":"2026-11-14","start":{"placeId":"start","departAt":"09:00"},"end":{"placeId":"start","arriveBy":"17:00"},"places":[{"placeId":"p1","priority":"must","stayMin":60},{"placeId":"p2","priority":"want","stayMin":60}]}`
	store.count = service.MaxItineraries
	call("POST", "/itineraries", create, "", 422, nil)
	store.count = 0
	call("POST", "/itineraries", create, "", 201, &trip)
	if len(trip.Items) != 2 || len(trip.Legs) != 3 || trip.Legs[2].ToItemID != "end" || trip.End.Name != "start" || trip.End.ArriveAt != "2026-11-14T11:30:00+09:00" || trip.Summary.EndAt != trip.End.ArriveAt {
		t.Fatalf("%+v", trip)
	}
	call("GET", "/me/itineraries?limit=5", "", "", 200, nil)
	call("GET", "/itineraries/trip", "", "", 200, nil)
	call("PUT", "/itineraries/trip/places", `{"places":[{"placeId":"p1","priority":"must","stayMin":60},{"placeId":"p2","priority":"want","stayMin":60}]}`, "1", 200, &trip)
	call("PUT", "/itineraries/trip/places", `{"places":[{"placeId":"p1","priority":"must","stayMin":60}]}`, "1", 409, nil)
	var proposal service.Replan
	delay := 40
	body, _ := json.Marshal(service.ReplanInput{CurrentItemID: trip.Items[0].ItemID, DelayMin: &delay})
	call("POST", "/itineraries/trip/replans", string(body), "", 200, &proposal)
	// アルゴリズムの案（時刻をずらす、優先度の低い予定を外す）と、Gemini の代替案をすべて返す。
	// Gemini の1案目はアルゴリズムの案1と同じ結果になるため1つにまとまる。
	sources := []string{}
	for _, option := range proposal.Options {
		sources = append(sources, option.Source+":"+option.Label)
	}
	if strings.Join(sources, ",") != "algorithm:順番はそのままで時刻をずらす,algorithm:「p2」を外して後の予定を守る,ai:近くの施設に置き換え" {
		t.Fatalf("%v", sources)
	}
	optionID := proposal.Options[0].OptionID
	var explanation service.Explanation
	call("GET", "/itineraries/trip/replans/rp/explanation?optionId="+optionID, "", "", 200, &explanation)
	if explanation.Status != "ready" || explanation.Text == "" || len(explanation.Reasons) != 1 || explanation.Reasons[0].Type != "retime" {
		t.Fatalf("%+v", explanation)
	}
	accept, _ := json.Marshal(map[string]string{"optionId": optionID})
	call("POST", "/itineraries/trip/replans/rp/accept", string(accept), "2", 200, &trip)
	if trip.Items[0].Status != "current" {
		t.Fatalf("current item lost: %+v", trip.Items)
	}
	current := trip.Items[0]
	visits := []service.Visit{}
	for _, item := range trip.Items {
		visits = append(visits, service.Visit{PlaceID: item.PlaceID, Priority: item.Priority, StayMin: item.StayMin})
	}
	edit, _ := json.Marshal(map[string]any{"places": visits})
	call("PUT", "/itineraries/trip/places", string(edit), "3", 200, &trip)
	if !reflect.DeepEqual(trip.Items[0], current) {
		t.Fatalf("editing rewrote current item: before=%+v after=%+v", current, trip.Items[0])
	}
	changeEnd, _ := json.Marshal(map[string]any{"end": map[string]any{"placeId": "p2", "arriveBy": "17:30"}, "places": visits})
	call("PUT", "/itineraries/trip/places", string(changeEnd), "4", 200, &trip)
	if trip.End.Name != "p2" || trip.End.ArriveBy != "17:30" || trip.Version != 5 {
		t.Fatalf("end not updated after start: %+v", trip.End)
	}
	changeStart, _ := json.Marshal(map[string]any{"start": map[string]any{"placeId": "p2", "departAt": "09:00"}, "places": visits})
	call("PUT", "/itineraries/trip/places", string(changeStart), "5", 400, nil)
	removeCurrent, _ := json.Marshal(map[string]any{"places": visits[1:]})
	call("PUT", "/itineraries/trip/places", string(removeCurrent), "5", 400, nil)
	after := trip.Items[len(trip.Items)-1].ItemID
	var suggestions service.SuggestResult
	call("GET", "/itineraries/trip/suggestions?from=2026-11-14T13:00:00%2B09:00&to=2026-11-14T14:00:00%2B09:00&afterItemId="+after, "", "", 200, &suggestions)
	// 60分の空き時間から前後の移動（各10分）を除いた40分に、AI の滞在120分を収める。
	if len(suggestions.Suggestions) != 1 || suggestions.Suggestions[0].Place.PlaceID != "near" || suggestions.Suggestions[0].StayMin != 40 || suggestions.Suggestions[0].LegToNext.DurationMin != 10 || len(suggestions.Ideas) != 1 {
		t.Fatalf("%+v", suggestions)
	}
	add, _ := json.Marshal(service.AddInput{PlaceID: "p3", Priority: "optional", StayMin: 30, InsertAfterItemID: after})
	call("POST", "/itineraries/trip/items", string(add), "5", 200, &trip)
	if len(trip.Items) != 3 || trip.Version != 6 || trip.Legs[len(trip.Legs)-1].ToItemID != "end" || trip.Legs[len(trip.Legs)-1].FromItemID != trip.Items[2].ItemID {
		t.Fatalf("%+v", trip)
	}
	// 旅行日を変えると、滞在中の予定も含めて作り直す。
	visits = []service.Visit{}
	for _, item := range trip.Items {
		visits = append(visits, service.Visit{PlaceID: item.PlaceID, Priority: item.Priority, StayMin: item.StayMin})
	}
	moved, _ := json.Marshal(map[string]any{"date": "2026-11-21", "end": map[string]any{"placeId": "p1", "arriveBy": "18:00"}, "places": visits})
	call("PUT", "/itineraries/trip/places", string(moved), "6", 200, &trip)
	if trip.Date != "2026-11-21" || trip.Items[0].Status != "upcoming" || trip.End.ArriveBy != "18:00" || trip.End.Name != "p1" || trip.ExpiresAt != "2026-12-21T00:00:00+09:00" {
		t.Fatalf("%+v", trip)
	}
	var nearby struct {
		Places []service.NearbyPlace `json:"places"`
	}
	call("GET", "/places/nearby?lat=35&lng=139&radius=500", "", "", 200, &nearby)
	if len(nearby.Places) != 1 || nearby.Places[0].TypeLabel != "駅" {
		t.Fatalf("%+v", nearby)
	}
	var detail service.PlaceDetail
	call("GET", "/places/onsen?date=2026-11-14", "", "", 200, &detail)
	if detail.TypeLabel != "温泉" || detail.OpeningHours == nil || detail.OpeningHours.ClosesAt != "21:00" || detail.Price.Amount == nil || *detail.Price.Amount != 600 {
		t.Fatalf("%+v", detail)
	}
	call("GET", "/places/onsen?date=2026-11-15", "", "", 200, &detail)
	if detail.OpeningHours != nil {
		t.Fatalf("closed day: %+v", detail.OpeningHours)
	}
	version := strconv.Itoa(trip.Version)
	call("PATCH", "/itineraries/trip", `{"title":"山あいの温泉町めぐり"}`, version, 200, &trip)
	if trip.Title != "山あいの温泉町めぐり" || strconv.Itoa(trip.Version) == version {
		t.Fatalf("%+v", trip)
	}
	var copied service.Itinerary
	store.count = service.MaxItineraries
	call("POST", "/itineraries/trip/copy", `{"date":"2026-12-12"}`, "", 422, nil)
	store.count = 0
	call("POST", "/itineraries/trip/copy", `{"date":"2026-12-12"}`, "", 201, &copied)
	if copied.Date != "2026-12-12" || copied.Title != trip.Title || len(copied.Items) != len(trip.Items) || copied.Items[0].Status != "upcoming" || copied.End.ArriveBy != trip.End.ArriveBy || copied.Version != 1 {
		t.Fatalf("%+v", copied)
	}
	call("DELETE", "/itineraries/trip", "", "1", 204, nil)
	call("GET", "/itineraries/trip", "", "", 404, nil)
}
