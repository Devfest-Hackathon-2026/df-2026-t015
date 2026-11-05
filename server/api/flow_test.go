package api

import (
	"context"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"net/http/httptest"
	"reflect"
	"strings"
	"testing"

	"github.com/create-alt/gen-TLE/server/internal/service"
)

type flowStore struct {
	service.Store
	trip     service.Itinerary
	proposal service.Replan
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
func (s *flowStore) List(context.Context, string) ([]service.ItineraryEntry, error) {
	return []service.ItineraryEntry{{ID: s.trip.ID}}, nil
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

func (flowTransport) RoundTrip(r *http.Request) (*http.Response, error) {
	var data any
	switch {
	case strings.HasSuffix(r.URL.Path, "places:autocomplete"):
		data = map[string]any{"suggestions": []any{map[string]any{"placePrediction": map[string]any{"placeId": "p1", "structuredFormat": map[string]any{"mainText": map[string]string{"text": "公園"}, "secondaryText": map[string]string{"text": "東京都"}}}}}}
	case strings.HasSuffix(r.URL.Path, "places:searchText"):
		data = map[string]any{"places": []any{map[string]any{"id": "p3", "displayName": map[string]string{"text": "公園3"}, "location": map[string]int{"latitude": 35, "longitude": 139}}}}
	case strings.HasPrefix(r.URL.Path, "/v1/places/"):
		id := strings.TrimPrefix(r.URL.Path, "/v1/places/")
		data = map[string]any{"id": id, "displayName": map[string]string{"text": id}, "location": map[string]int{"latitude": 35, "longitude": 139}}
	case strings.Contains(r.URL.Path, "computeRoutes"):
		data = map[string]any{"routes": []any{map[string]string{"duration": "600s"}}}
	case strings.Contains(r.URL.Path, "generateContent"):
		var request struct {
			Contents []struct {
				Parts []struct {
					Text string `json:"text"`
				} `json:"parts"`
			} `json:"contents"`
			Config struct {
				Schema struct {
					Properties map[string]any `json:"properties"`
				} `json:"responseJsonSchema"`
			} `json:"generationConfig"`
		}
		if err := json.NewDecoder(r.Body).Decode(&request); err != nil {
			return nil, err
		}
		var output any
		switch {
		case request.Config.Schema.Properties["queries"] != nil:
			output = map[string]any{"queries": []any{map[string]string{"query": "公園", "reason": "散歩に合う"}}}
		case request.Config.Schema.Properties["placeIds"] != nil:
			prompt := request.Contents[0].Parts[0].Text
			var data struct {
				Request service.PlanInput `json:"request"`
			}
			if err := json.Unmarshal([]byte(prompt[strings.Index(prompt, "{"):]), &data); err != nil {
				return nil, err
			}
			ids := []string{}
			for _, visit := range data.Request.Places {
				ids = append(ids, visit.PlaceID)
			}
			output = map[string]any{"placeIds": ids}
		case request.Config.Schema.Properties["options"] != nil:
			output = map[string]any{"options": []any{map[string]any{"placeIds": []string{"p2"}}, map[string]any{"placeIds": []string{"p3"}}}}
		case request.Config.Schema.Properties["text"] != nil:
			output = map[string]string{"text": "遅延に合わせて時刻を変更しました。"}
		case request.Config.Schema.Properties["suggestions"] != nil:
			output = map[string]any{"suggestions": []any{map[string]any{"placeId": "p3", "reason": "近くで散歩できる", "stayMin": 30}}}
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
	app := &service.App{Store: store, Verify: func(context.Context, string) (string, error) { return "owner", nil }, Maps: &service.Maps{HTTP: client}, AI: &service.Gemini{HTTP: client, Model: "test"}}
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
	call("POST", "/places/interpret", `{"text":"公園を散歩したい"}`, "", 200, nil)
	var trip service.Itinerary
	call("POST", "/itineraries", `{"title":"旅","date":"2026-11-14","start":{"placeId":"start","departAt":"09:00"},"endBy":"17:00","places":[{"placeId":"p1","priority":"must","stayMin":60},{"placeId":"p2","priority":"want","stayMin":60}]}`, "", 201, &trip)
	if len(trip.Items) != 2 {
		t.Fatalf("%+v", trip)
	}
	call("GET", "/me/itineraries", "", "", 200, nil)
	call("GET", "/itineraries/trip", "", "", 200, nil)
	call("PUT", "/itineraries/trip/places", `{"places":[{"placeId":"p1","priority":"must","stayMin":60},{"placeId":"p2","priority":"want","stayMin":60}]}`, "1", 200, &trip)
	call("PUT", "/itineraries/trip/places", `{"places":[{"placeId":"p1","priority":"must","stayMin":60}]}`, "1", 409, nil)
	var proposal service.Replan
	delay := 40
	body, _ := json.Marshal(service.ReplanInput{CurrentItemID: trip.Items[0].ItemID, DelayMin: &delay})
	call("POST", "/itineraries/trip/replans", string(body), "", 200, &proposal)
	if len(proposal.Options) != 2 {
		t.Fatalf("%+v", proposal)
	}
	optionID := proposal.Options[0].OptionID
	call("GET", "/itineraries/trip/replans/rp/explanation?optionId="+optionID, "", "", 200, nil)
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
	removeCurrent, _ := json.Marshal(map[string]any{"places": visits[1:]})
	call("PUT", "/itineraries/trip/places", string(removeCurrent), "4", 400, nil)
	after := trip.Items[len(trip.Items)-1].ItemID
	var suggestions struct {
		Suggestions []service.Suggestion `json:"suggestions"`
	}
	call("GET", "/itineraries/trip/suggestions?from=2026-11-14T13:00:00%2B09:00&to=2026-11-14T14:00:00%2B09:00&afterItemId="+after, "", "", 200, &suggestions)
	if len(suggestions.Suggestions) != 1 {
		t.Fatalf("%+v", suggestions)
	}
	add, _ := json.Marshal(service.AddInput{PlaceID: "p3", Priority: "optional", StayMin: 30, InsertAfterItemID: after})
	call("POST", "/itineraries/trip/items", string(add), "4", 200, &trip)
	if len(trip.Items) != 3 || trip.Version != 5 {
		t.Fatalf("%+v", trip)
	}
}
