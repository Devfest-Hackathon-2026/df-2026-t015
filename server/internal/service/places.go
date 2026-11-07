package service

import (
	"context"
	"math"
	"net/url"
	"strconv"
	"time"
)

// NearbyPlace は GET /places/nearby の1件。typeLabel は画面に出す施設の種類（駅、温泉など）。
type NearbyPlace struct {
	PlaceID   string `json:"placeId"`
	Name      string `json:"name"`
	Address   string `json:"address"`
	Location  Point  `json:"location"`
	TypeLabel string `json:"typeLabel"`
}

// PlaceDetail は GET /places/:placeId の応答。
type PlaceDetail struct {
	Place        Place         `json:"place"`
	TypeLabel    string        `json:"typeLabel"`
	OpeningHours *OpeningHours `json:"openingHours"`
	Price        Price         `json:"price"`
}

const nearbyMask = "places.id,places.displayName,places.formattedAddress,places.location,places.primaryTypeDisplayName"

// distance は2地点の距離（m）。
func distance(a, b Point) float64 {
	const earth = 6371000.0
	lat1, lat2 := a.Lat*math.Pi/180, b.Lat*math.Pi/180
	dLat, dLng := lat2-lat1, (b.Lng-a.Lng)*math.Pi/180
	h := math.Sin(dLat/2)*math.Sin(dLat/2) + math.Cos(lat1)*math.Cos(lat2)*math.Sin(dLng/2)*math.Sin(dLng/2)
	return 2 * earth * math.Asin(math.Min(1, math.Sqrt(h)))
}

// Nearby は center から radius（m）以内の施設を最大20件返す。
// query がなければ Nearby Search、あれば Text Search で探して範囲外を除く。
func (m *Maps) Nearby(ctx context.Context, center Point, radius int, query string) ([]NearbyPlace, error) {
	values, err := m.nearby(ctx, center, radius, query, nearbyMask)
	if err != nil {
		return nil, err
	}
	places := []NearbyPlace{}
	for _, value := range values {
		places = append(places, NearbyPlace{PlaceID: value.Place.PlaceID, Name: value.Place.Name, Address: value.Place.Address, Location: value.Place.Location, TypeLabel: value.TypeLabel})
	}
	return places, nil
}

type nearbyResult struct {
	Place     Place
	TypeLabel string
}

func (m *Maps) nearby(ctx context.Context, center Point, radius int, query, mask string) ([]nearbyResult, error) {
	circle := map[string]any{"circle": map[string]any{"center": map[string]float64{"latitude": center.Lat, "longitude": center.Lng}, "radius": radius}}
	var output struct {
		Places []mapPlace `json:"places"`
	}
	var err error
	if query == "" {
		input := map[string]any{"locationRestriction": circle, "maxResultCount": 20, "languageCode": "ja", "regionCode": "jp"}
		err = Request(ctx, m.HTTP, "POST", "https://places.googleapis.com/v1/places:searchNearby", m.headers(mask), input, &output)
	} else {
		input := map[string]any{"textQuery": query, "locationBias": circle, "pageSize": 20, "languageCode": "ja", "regionCode": "jp"}
		err = Request(ctx, m.HTTP, "POST", "https://places.googleapis.com/v1/places:searchText", m.headers(mask), input, &output)
	}
	if err != nil {
		return nil, err
	}
	places := []nearbyResult{}
	for _, value := range output.Places {
		p, err := value.place()
		if err != nil {
			return nil, err
		}
		if distance(center, p.Location) > float64(radius) || len(places) >= 20 {
			continue
		}
		places = append(places, nearbyResult{Place: p, TypeLabel: value.PrimaryType.Text})
	}
	return places, nil
}

// Detail は施設の詳しい情報と、date（日本時間）の営業時間を返す。
func (m *Maps) Detail(ctx context.Context, id string, date time.Time) (PlaceDetail, error) {
	if !ValidID(id) {
		return PlaceDetail{}, Invalid("施設IDが不正です")
	}
	var output mapPlace
	mask := "id,displayName,formattedAddress,location,regularOpeningHours,currentOpeningHours,primaryTypeDisplayName,priceRange"
	err := Request(ctx, m.HTTP, "GET", "https://places.googleapis.com/v1/places/"+url.PathEscape(id)+"?languageCode=ja", m.headers(mask), nil, &output)
	if err != nil {
		return PlaceDetail{}, err
	}
	p, err := output.place()
	if err != nil {
		return PlaceDetail{}, err
	}
	if p.PlaceID != id {
		return PlaceDetail{}, Upstream()
	}
	detail := PlaceDetail{Place: p, TypeLabel: output.PrimaryType.Text, Price: Price{Kind: "unknown"}}
	detail.OpeningHours = DayHours(output.Current, output.Hours, date)
	if r := output.PriceRange; r != nil && r.StartPrice != nil && r.StartPrice.CurrencyCode == "JPY" {
		if amount, err := strconv.Atoi(r.StartPrice.Units); err == nil && amount >= 0 {
			detail.Price = Price{Amount: &amount, Kind: "estimate", Source: "Google Maps"}
		}
	}
	return detail, nil
}

// DayHours は date の営業時間を返す。currentOpeningHours（直近7日、臨時営業を含む）に
// その日の区間があれば優先し、なければ通常営業時間の曜日で判定する。休みなら nil。
// 区間が複数ある日は、最初に開く時刻と最後に閉まる時刻を返す。
func DayHours(current, regular *Hours, date time.Time) *OpeningHours {
	date = date.In(JST)
	matchDate := func(point HourPoint) bool {
		return point.Date != nil && point.Date.Year == date.Year() && point.Date.Month == int(date.Month()) && point.Date.Day == date.Day()
	}
	pick := func(hours *Hours, match func(HourPoint) bool) (*OpeningHours, bool) {
		if hours == nil {
			return nil, false
		}
		// 24時間営業は close のない区間1つで表される。
		for _, period := range hours.Periods {
			if period.Close == nil {
				return &OpeningHours{OpensAt: "00:00", ClosesAt: "24:00"}, true
			}
		}
		found := false
		var opens, closes int
		var closesText string
		for _, period := range hours.Periods {
			if !match(period.Open) {
				continue
			}
			open := period.Open.Hour*60 + period.Open.Minute
			end := period.Close.Hour*60 + period.Close.Minute
			if period.Close.Day != period.Open.Day || end <= open {
				end += 24 * 60
			}
			if !found || open < opens {
				opens = open
			}
			if !found || end > closes {
				closes = end
				closesText = clockText(period.Close.Hour, period.Close.Minute)
			}
			found = true
		}
		if !found {
			return nil, false
		}
		return &OpeningHours{OpensAt: clockText(opens/60, opens%60), ClosesAt: closesText}, true
	}
	// currentOpeningHours は今日から7日分。その範囲の日は、区間がなければ臨時休業として扱う。
	today := time.Now().In(JST)
	today = time.Date(today.Year(), today.Month(), today.Day(), 0, 0, 0, 0, JST)
	day := time.Date(date.Year(), date.Month(), date.Day(), 0, 0, 0, 0, JST)
	if current != nil && !day.Before(today) && day.Before(today.AddDate(0, 0, 7)) {
		for _, period := range current.Periods {
			if period.Open.Date != nil {
				hours, _ := pick(current, matchDate)
				return hours
			}
		}
	}
	hours, _ := pick(regular, func(point HourPoint) bool { return point.Day == int(date.Weekday()) })
	return hours
}

func clockText(hour, minute int) string {
	return time.Date(2000, 1, 1, hour, minute, 0, 0, time.UTC).Format("15:04")
}
