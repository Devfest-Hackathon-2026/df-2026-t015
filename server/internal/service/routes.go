package service

import (
	"context"
	"math"
	"strings"
	"sync"
	"time"
)

// walkMaxMin は徒歩を選ぶ上限（分）。これより長い区間は、公共交通の結果があれば公共交通、なければ車にする。
const walkMaxMin = 20

// routeModes は Routes API に並行して問い合わせる移動手段。
// Routes API は日本の公共交通をほとんど返さないため、TRANSIT は結果が返ったときだけ使う。
var routeModes = []string{"WALK", "DRIVE", "TRANSIT"}

type routeResult struct {
	leg   Leg
	found bool
	err   error
}

func (w Waypoint) routeJSON() map[string]any {
	if w.PlaceID != "" && !w.HasLocation {
		return map[string]any{"placeId": w.PlaceID}
	}
	return map[string]any{"location": map[string]any{"latLng": map[string]float64{"latitude": w.Location.Lat, "longitude": w.Location.Lng}}}
}

// Route は from から to への移動を Google Routes API で求める。徒歩・車・公共交通を並行して調べ、
// 徒歩が walkMaxMin 分以内なら徒歩、それより長ければ公共交通（結果があるとき）、次に車（mode は taxi）を選ぶ。
func (m *Maps) Route(ctx context.Context, from, to Waypoint, depart time.Time) (Leg, error) {
	if from.Key() == to.Key() {
		return Leg{Mode: "walk", DepartAt: depart.Format(time.RFC3339), ArriveAt: depart.Format(time.RFC3339)}, nil
	}
	for _, w := range []Waypoint{from, to} {
		if (w.PlaceID == "" || w.HasLocation) && !ValidPoint(w.Location) {
			return Leg{}, Invalid("地点が不正です")
		}
	}
	results := make([]routeResult, len(routeModes))
	var wg sync.WaitGroup
	for i, mode := range routeModes {
		wg.Add(1)
		go func() {
			defer wg.Done()
			results[i] = m.computeRoute(ctx, from, to, mode, depart)
		}()
	}
	wg.Wait()
	walk, drive, transit := results[0], results[1], results[2]
	switch {
	case walk.found && walk.leg.DurationMin <= walkMaxMin:
		return walk.leg, nil
	case transit.found && transit.leg.Mode != "walk":
		return transit.leg, nil
	case drive.found:
		return drive.leg, nil
	case walk.found:
		return walk.leg, nil
	}
	// 公共交通の失敗は、日本では結果がないのが普通なので無視する。
	for _, result := range []routeResult{walk, drive} {
		if result.err != nil {
			return Leg{}, result.err
		}
	}
	return Leg{}, Fail(422, "ROUTE_NOT_FOUND", "指定した地点の間の経路が見つかりません")
}

func (m *Maps) computeRoute(ctx context.Context, from, to Waypoint, mode string, depart time.Time) routeResult {
	input := map[string]any{"origin": from.routeJSON(), "destination": to.routeJSON(), "travelMode": mode, "languageCode": "ja"}
	if mode == "TRANSIT" {
		input["departureTime"] = depart.UTC().Format(time.RFC3339)
	}
	var output struct {
		Routes []struct {
			Duration string `json:"duration"`
			Legs     []struct {
				Steps []struct {
					Transit *struct {
						Line struct {
							Name      string `json:"name"`
							NameShort string `json:"nameShort"`
							Vehicle   struct {
								Type string `json:"type"`
							} `json:"vehicle"`
						} `json:"transitLine"`
						Stops struct {
							ArrivalTime string `json:"arrivalTime"`
						} `json:"stopDetails"`
					} `json:"transitDetails"`
				} `json:"steps"`
			} `json:"legs"`
		} `json:"routes"`
	}
	mask := "routes.duration"
	if mode == "TRANSIT" {
		mask += ",routes.legs.steps.transitDetails"
	}
	if err := Request(ctx, m.HTTP, "POST", "https://routes.googleapis.com/directions/v2:computeRoutes", m.headers(mask), input, &output); err != nil {
		return routeResult{err: err}
	}
	if len(output.Routes) == 0 {
		return routeResult{}
	}
	route := output.Routes[0]
	duration, err := time.ParseDuration(route.Duration)
	if err != nil || duration < 0 {
		return routeResult{err: Upstream()}
	}
	leg := Leg{Mode: "walk", DepartAt: depart.Format(time.RFC3339)}
	if mode == "DRIVE" {
		leg.Mode = "taxi"
	}
	names := []string{}
	for _, part := range route.Legs {
		for _, step := range part.Steps {
			if step.Transit == nil {
				continue
			}
			if step.Transit.Line.Vehicle.Type == "BUS" || step.Transit.Line.Vehicle.Type == "TROLLEYBUS" {
				if leg.Mode != "train" {
					leg.Mode = "bus"
				}
			} else {
				leg.Mode = "train"
			}
			name := step.Transit.Line.NameShort
			if name == "" {
				name = step.Transit.Line.Name
			}
			if name != "" {
				names = append(names, name)
			}
			// 待ち時間を含めるため、最後の降車時刻が所要時間より後ならそちらを使う。
			if arrival, err := time.Parse(time.RFC3339, step.Transit.Stops.ArrivalTime); err == nil && arrival.Sub(depart) > duration {
				duration = arrival.Sub(depart)
			}
		}
	}
	leg.DurationMin = int(math.Ceil(duration.Minutes()))
	leg.ArriveAt = depart.Add(time.Duration(leg.DurationMin) * time.Minute).Format(time.RFC3339)
	if len(names) > 0 {
		name := strings.Join(names, " / ")
		leg.LineName = &name
	}
	return routeResult{leg: leg, found: true}
}
