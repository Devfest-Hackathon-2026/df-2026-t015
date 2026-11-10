package service

import (
	"context"
	"encoding/json"
	"fmt"
	"math"
	"net/http"
	"net/url"
	"strings"
	"sync"
	"time"
)

type Transit struct {
	Key       string
	HTTP      *http.Client
	mu        sync.Mutex
	condition string
}

type transitType string

func (mode *transitType) UnmarshalJSON(data []byte) error {
	var text string
	if err := json.Unmarshal(data, &text); err == nil {
		*mode = transitType(text)
		return nil
	}
	var value struct {
		Text string `json:"text"`
	}
	if err := json.Unmarshal(data, &value); err != nil {
		return err
	}
	*mode = transitType(value.Text)
	return nil
}

type transitState struct {
	Datetime struct {
		Text string `json:"text"`
	} `json:"Datetime"`
}

func (t *Transit) searchCondition(ctx context.Context) (string, error) {
	t.mu.Lock()
	defer t.mu.Unlock()
	if t.condition != "" {
		return t.condition, nil
	}
	query := url.Values{"key": {t.Key}, "plane": {"never"}, "ship": {"never"}}
	var output struct {
		ResultSet struct {
			Condition string          `json:"Condition"`
			Error     json.RawMessage `json:"Error"`
		} `json:"ResultSet"`
	}
	err := Request(ctx, t.HTTP, "GET", "https://mixway.ekispert.jp/v1/json/toolbox/course/condition?"+query.Encode(), nil, nil, &output)
	if err != nil {
		return "", err
	}
	if output.ResultSet.Condition == "" || len(output.ResultSet.Error) > 0 && string(output.ResultSet.Error) != "null" {
		return "", Upstream()
	}
	t.condition = output.ResultSet.Condition
	return t.condition, nil
}

func (t *Transit) Route(ctx context.Context, from, to Point, depart time.Time) (Leg, error) {
	if t == nil || t.Key == "" {
		return Leg{}, Fail(503, "TRANSIT_UNAVAILABLE", "公共交通の接続設定がありません。サーバーに MIXWAY_API_KEY を設定してください")
	}
	if !ValidPoint(from) || !ValidPoint(to) || depart.IsZero() {
		return Leg{}, Invalid("経路の地点・出発日時が不正です")
	}
	condition, err := t.searchCondition(ctx)
	if err != nil {
		return Leg{}, err
	}
	depart = depart.In(JST)
	// 検索は分単位なので、秒があるときは出発前の便を選ばないよう切り上げる。
	searchAt := depart.Truncate(time.Minute)
	if searchAt.Before(depart) {
		searchAt = searchAt.Add(time.Minute)
	}
	query := url.Values{
		"key": {t.Key}, "viaList": {fmt.Sprintf("%g,%g:%g,%g", from.Lat, from.Lng, to.Lat, to.Lng)},
		"date": {searchAt.Format("20060102")}, "time": {searchAt.Format("1504")}, "searchType": {"departure"},
		"conditionDetail": {condition}, "mode": {"public"}, "maxCarDistance": {"0"}, "applyMaxCarDistanceStrict": {"true"},
	}
	var output struct {
		ResultSet *struct {
			APIVersion    string          `json:"apiVersion"`
			EngineVersion string          `json:"engineVersion"`
			Error         json.RawMessage `json:"Error"`
			Course        []struct {
				Route struct {
					Line []struct {
						Type      transitType  `json:"Type"`
						Name      string       `json:"Name"`
						Departure transitState `json:"DepartureState"`
						Arrival   transitState `json:"ArrivalState"`
					} `json:"Line"`
				} `json:"Route"`
			} `json:"Course"`
		} `json:"ResultSet"`
	}
	err = Request(ctx, t.HTTP, "GET", "https://mixway.ekispert.jp/v1/json/search/course/extreme?"+query.Encode(), nil, nil, &output)
	if err != nil {
		return Leg{}, err
	}
	result := output.ResultSet
	if result == nil || len(result.Error) > 0 && string(result.Error) != "null" {
		return Leg{}, Upstream()
	}
	if len(result.Course) == 0 && result.APIVersion == "" && result.EngineVersion == "" {
		return Leg{}, Upstream()
	}
	var best Leg
	var bestArrival time.Time
	for _, course := range result.Course {
		if len(course.Route.Line) == 0 {
			return Leg{}, Upstream()
		}
		allowed := true
		for _, line := range course.Route.Line {
			switch line.Type {
			case "train", "bus", "walk":
			case "plane", "ship", "car", "cycle", "demand", "strange":
				allowed = false
			default:
				return Leg{}, Upstream()
			}
		}
		if !allowed {
			continue
		}
		last := depart
		mode := "walk"
		names := []string{}
		for _, line := range course.Route.Line {
			start, err := transitTime(line.Departure.Datetime.Text, last)
			if err != nil {
				return Leg{}, err
			}
			arrival, err := transitTime(line.Arrival.Datetime.Text, start)
			if err != nil {
				return Leg{}, err
			}
			last = arrival
			if line.Type == "train" {
				mode = "train"
			} else if line.Type == "bus" && mode != "train" {
				mode = "bus"
			}
			if line.Type != "walk" && line.Name != "" {
				names = append(names, line.Name)
			}
		}
		if !bestArrival.IsZero() && !last.Before(bestArrival) {
			continue
		}
		best = Leg{Mode: mode, DurationMin: int(math.Ceil(last.Sub(depart).Minutes())), DepartAt: depart.Format(time.RFC3339), ArriveAt: last.Format(time.RFC3339)}
		if len(names) > 0 {
			name := strings.Join(names, " / ")
			best.LineName = &name
		}
		bestArrival = last
	}
	if bestArrival.IsZero() {
		return Leg{}, Fail(422, "ROUTE_NOT_FOUND", "指定した日時・地点の電車・バス・徒歩経路が見つかりません")
	}
	return best, nil
}

func transitTime(value string, earliest time.Time) (time.Time, error) {
	if strings.Contains(value, "T") {
		parsed, err := time.Parse(time.RFC3339, value)
		if err != nil || parsed.Before(earliest) {
			return time.Time{}, Upstream()
		}
		return parsed.In(JST), nil
	}
	clock, err := time.Parse("15:04:05-07:00", value)
	if err != nil {
		return time.Time{}, Upstream()
	}
	_, offset := clock.Zone()
	if offset != 9*60*60 {
		return time.Time{}, Upstream()
	}
	// operation は運行日を示す。日付のない時刻は区間順に日付を繰り越す。
	parsed := time.Date(earliest.Year(), earliest.Month(), earliest.Day(), clock.Hour(), clock.Minute(), clock.Second(), 0, JST)
	if parsed.Before(earliest) {
		parsed = parsed.AddDate(0, 0, 1)
	}
	return parsed, nil
}
