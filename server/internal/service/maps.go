package service

import (
	"context"
	"fmt"
	"log"
	"net/http"
	"net/url"
)

// Maps は Google の Places API (New) と Routes API の呼び出し先。Key があれば API キーで、
// なければ ADC のトークン（HTTP に付けるクライアントを渡す）と課金先の Project で呼ぶ。
type Maps struct {
	Key     string
	HTTP    *http.Client
	Project string
}

func (m *Maps) mode() string {
	if m.Key != "" {
		return "API キー"
	}
	return "ADC（" + m.Project + "）"
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
	if m.Key == "" {
		return map[string]string{"X-Goog-User-Project": m.Project, "X-Goog-FieldMask": mask}
	}
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
			log.Printf("upstream places:autocomplete: unexpected suggestion (placeId=%q mainText=%q)", p.PlaceID, p.Format.Main.Text)
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

func (m *Maps) location(ctx context.Context, waypoint Waypoint) (Point, error) {
	if waypoint.HasLocation || waypoint.PlaceID == "" {
		if !ValidPoint(waypoint.Location) {
			return Point{}, Invalid("地点が不正です")
		}
		return waypoint.Location, nil
	}
	place, err := m.Details(ctx, waypoint.PlaceID)
	return place.Location, err
}
