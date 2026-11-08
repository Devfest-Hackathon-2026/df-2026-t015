package service

import (
	"context"
	"fmt"
	"math"
	"net/http"
	"net/url"
	"strings"
	"time"
)

type Maps struct {
	Key  string
	HTTP *http.Client
}

type HourPoint struct {
	Day    int `json:"day"`
	Hour   int `json:"hour"`
	Minute int `json:"minute"`
	// Date は currentOpeningHours の区間にだけ入る、その区間の日付。
	Date *struct {
		Year  int `json:"year"`
		Month int `json:"month"`
		Day   int `json:"day"`
	} `json:"date,omitempty"`
}

type Period struct {
	Open  HourPoint  `json:"open"`
	Close *HourPoint `json:"close"`
}

type Hours struct {
	Periods []Period `json:"periods"`
}

type mapPlace struct {
	ID          string `json:"id"`
	DisplayName struct {
		Text string `json:"text"`
	} `json:"displayName"`
	FormattedAddress string `json:"formattedAddress"`
	Location         *struct {
		Latitude  float64 `json:"latitude"`
		Longitude float64 `json:"longitude"`
	} `json:"location"`
	Hours       *Hours `json:"regularOpeningHours"`
	Current     *Hours `json:"currentOpeningHours"`
	PrimaryType struct {
		Text string `json:"text"`
	} `json:"primaryTypeDisplayName"`
	PriceRange *struct {
		StartPrice *struct {
			CurrencyCode string `json:"currencyCode"`
			Units        string `json:"units"`
		} `json:"startPrice"`
	} `json:"priceRange"`
}

func (p mapPlace) place() (Place, error) {
	if p.Location == nil {
		return Place{}, Upstream()
	}
	point := Point{Lat: p.Location.Latitude, Lng: p.Location.Longitude}
	if !ValidID(p.ID) || !Text(p.DisplayName.Text, 1, 500) || !ValidPoint(point) {
		return Place{}, Upstream()
	}
	return Place{PlaceID: p.ID, Name: p.DisplayName.Text, Address: p.FormattedAddress, Location: point, Hours: p.Hours}, nil
}

func (m *Maps) headers(mask string) map[string]string {
	return map[string]string{"X-Goog-Api-Key": m.Key, "X-Goog-FieldMask": mask}
}

func bias(point *Point) map[string]any {
	return map[string]any{"circle": map[string]any{"center": map[string]float64{"latitude": point.Lat, "longitude": point.Lng}, "radius": 10000}}
}

func (m *Maps) Autocomplete(ctx context.Context, query string, near *Point) ([]Place, error) {
	input := map[string]any{"input": query, "languageCode": "ja", "includedRegionCodes": []string{"jp"}}
	if near != nil {
		input["locationBias"] = bias(near)
	}
	var output struct {
		Suggestions []struct {
			Prediction struct {
				PlaceID string `json:"placeId"`
				Format  struct {
					Main struct {
						Text string `json:"text"`
					} `json:"mainText"`
					Secondary struct {
						Text string `json:"text"`
					} `json:"secondaryText"`
				} `json:"structuredFormat"`
			} `json:"placePrediction"`
		} `json:"suggestions"`
	}
	err := Request(ctx, m.HTTP, "POST", "https://places.googleapis.com/v1/places:autocomplete", m.headers("suggestions.placePrediction.placeId,suggestions.placePrediction.structuredFormat"), input, &output)
	if err != nil {
		return nil, err
	}
	places := []Place{}
	for _, suggestion := range output.Suggestions {
		p := suggestion.Prediction
		if !ValidID(p.PlaceID) || p.Format.Main.Text == "" {
			return nil, Upstream()
		}
		places = append(places, Place{PlaceID: p.PlaceID, Name: p.Format.Main.Text, Address: p.Format.Secondary.Text})
	}
	return places, nil
}

func (m *Maps) Details(ctx context.Context, id string) (Place, error) {
	if !ValidID(id) {
		return Place{}, Invalid("施設IDが不正です")
	}
	// shortcut: 通常営業時間で判定する。臨時休業に対応するときは日付別の営業時間も取得する。
	var output mapPlace
	err := Request(ctx, m.HTTP, "GET", "https://places.googleapis.com/v1/places/"+url.PathEscape(id)+"?languageCode=ja", m.headers("id,displayName,formattedAddress,location,regularOpeningHours"), nil, &output)
	if err != nil {
		return Place{}, err
	}
	p, err := output.place()
	if err == nil && p.PlaceID != id {
		return Place{}, Upstream()
	}
	return p, err
}

func (m *Maps) Search(ctx context.Context, query string, near *Point) ([]Place, error) {
	input := map[string]any{"textQuery": query, "languageCode": "ja", "pageSize": 5}
	if near != nil {
		input["locationBias"] = bias(near)
	}
	var output struct {
		Places []mapPlace `json:"places"`
	}
	err := Request(ctx, m.HTTP, "POST", "https://places.googleapis.com/v1/places:searchText", m.headers("places.id,places.displayName,places.formattedAddress,places.location,places.regularOpeningHours"), input, &output)
	if err != nil {
		return nil, err
	}
	places := []Place{}
	for _, value := range output.Places {
		p, err := value.place()
		if err != nil {
			return nil, err
		}
		places = append(places, p)
	}
	return places, nil
}

// Key は経路キャッシュ用の地点の識別子。
func (w Waypoint) Key() string {
	if w.PlaceID != "" {
		return "place:" + w.PlaceID
	}
	return fmt.Sprintf("geo:%.6f,%.6f", w.Location.Lat, w.Location.Lng)
}

func (w Waypoint) routeJSON() map[string]any {
	if w.PlaceID != "" {
		return map[string]any{"placeId": w.PlaceID}
	}
	return map[string]any{"location": map[string]any{"latLng": map[string]float64{"latitude": w.Location.Lat, "longitude": w.Location.Lng}}}
}

func (m *Maps) Route(ctx context.Context, from, to Waypoint, depart time.Time) (Leg, error) {
	best := Leg{Mode: "walk", DepartAt: depart.Format(time.RFC3339)}
	if from.Key() == to.Key() {
		best.ArriveAt = best.DepartAt
		return best, nil
	}
	found := false
	for _, mode := range []string{"WALK", "TRANSIT"} {
		input := map[string]any{"origin": from.routeJSON(), "destination": to.routeJSON(), "travelMode": mode, "languageCode": "ja"}
		if mode == "TRANSIT" {
			// Maps の公共交通検索は過去7日〜未来100日だけを受け付ける。
			if depart.Before(time.Now().Add(-7*24*time.Hour)) || depart.After(time.Now().Add(100*24*time.Hour)) {
				continue
			}
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
		err := Request(ctx, m.HTTP, "POST", "https://routes.googleapis.com/directions/v2:computeRoutes", m.headers("routes.duration,routes.legs.steps.transitDetails"), input, &output)
		if err != nil {
			return Leg{}, err
		}
		if len(output.Routes) == 0 {
			continue
		}
		route := output.Routes[0]
		duration, err := time.ParseDuration(route.Duration)
		if err != nil || duration < 0 {
			return Leg{}, Upstream()
		}
		leg := Leg{Mode: "walk", DepartAt: depart.Format(time.RFC3339)}
		names := []string{}
		for _, part := range route.Legs {
			for _, step := range part.Steps {
				if step.Transit == nil {
					continue
				}
				leg.Mode = "train"
				if step.Transit.Line.Vehicle.Type == "BUS" {
					leg.Mode = "bus"
				}
				name := step.Transit.Line.NameShort
				if name == "" {
					name = step.Transit.Line.Name
				}
				if name != "" {
					names = append(names, name)
				}
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
		if !found || leg.DurationMin < best.DurationMin {
			best = leg
			found = true
		}
	}
	if !found {
		return Leg{}, Upstream()
	}
	return best, nil
}
