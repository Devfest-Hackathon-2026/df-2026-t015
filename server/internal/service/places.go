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

// DayHours は date（日本時間）の営業時間を返す。休みなら nil。
//
// 今日から7日以内で currentOpeningHours（臨時営業・臨時休業を含む）があればそれだけを使い、
// periods が空配列なら臨時休業として nil を返す（通常営業時間には戻さない）。
// それ以外は通常営業時間で判定する。
//
// 営業区間は開店日ではなく「その日に重なるか」で判定する。前日から続く深夜営業
// （金曜22時〜土曜2時を土曜で取得など）は opensAt "00:00" として含める。
// 区間が複数ある日は、その日の最初に開いている時刻と、最後に閉まる時刻（翌日にかかれば翌日の時刻）を返す。
func DayHours(current, regular *Hours, date time.Time) *OpeningHours {
	date = date.In(JST)
	day := time.Date(date.Year(), date.Month(), date.Day(), 0, 0, 0, 0, JST)
	today := time.Now().In(JST)
	today = time.Date(today.Year(), today.Month(), today.Day(), 0, 0, 0, 0, JST)
	// periods のキーがない（nil）場合は営業時間が不明なので、通常営業時間で判定する。
	if current != nil && current.Periods != nil && !day.Before(today) && day.Before(today.AddDate(0, 0, 7)) {
		return hoursOn(current, day)
	}
	return hoursOn(regular, day)
}

// hoursOn は hours の営業区間のうち、day（0時〜24時）に重なるものから営業時間を作る。
func hoursOn(hours *Hours, day time.Time) *OpeningHours {
	if hours == nil {
		return nil
	}
	// 24時間営業は close のない区間1つで表される。
	for _, period := range hours.Periods {
		if period.Close == nil {
			return &OpeningHours{OpensAt: "00:00", ClosesAt: "24:00"}
		}
	}
	dayEnd := day.AddDate(0, 0, 1)
	var opens, closes time.Time
	for _, period := range hours.Periods {
		for _, span := range periodSpans(period, day) {
			if !span[1].After(day) || !span[0].Before(dayEnd) {
				continue
			}
			start := span[0]
			if start.Before(day) {
				start = day
			}
			if opens.IsZero() || start.Before(opens) {
				opens = start
			}
			if closes.IsZero() || span[1].After(closes) {
				closes = span[1]
			}
		}
	}
	if opens.IsZero() {
		return nil
	}
	closesText := closes.Format("15:04")
	if closes.Equal(dayEnd) {
		closesText = "24:00"
	}
	return &OpeningHours{OpensAt: opens.Format("15:04"), ClosesAt: closesText}
}

// periodSpans は営業区間を、day の前後の週に置いた開店・閉店の日時にする。
// 日付つきの区間（currentOpeningHours）はその日付だけ、曜日だけの区間は前週・今週・翌週に置く。
func periodSpans(period Period, day time.Time) [][2]time.Time {
	if period.Close == nil || !validPoint(period.Open) || !validPoint(*period.Close) {
		return nil
	}
	clock := func(base time.Time, point HourPoint) time.Time {
		return base.Add(time.Duration(point.Hour*60+point.Minute) * time.Minute)
	}
	if d := period.Open.Date; d != nil {
		openDay := time.Date(d.Year, time.Month(d.Month), d.Day, 0, 0, 0, 0, JST)
		closeDay := openDay.AddDate(0, 0, (period.Close.Day-period.Open.Day+7)%7)
		if c := period.Close.Date; c != nil {
			closeDay = time.Date(c.Year, time.Month(c.Month), c.Day, 0, 0, 0, 0, JST)
		}
		open, close := clock(openDay, period.Open), clock(closeDay, *period.Close)
		if !close.After(open) {
			close = close.AddDate(0, 0, 1)
		}
		return [][2]time.Time{{open, close}}
	}
	sunday := day.AddDate(0, 0, -int(day.Weekday()))
	open := clock(sunday.AddDate(0, 0, period.Open.Day), period.Open)
	close := clock(sunday.AddDate(0, 0, period.Close.Day), *period.Close)
	if !close.After(open) {
		close = close.AddDate(0, 0, 7)
	}
	spans := [][2]time.Time{}
	for _, offset := range []int{-7, 0, 7} {
		spans = append(spans, [2]time.Time{open.AddDate(0, 0, offset), close.AddDate(0, 0, offset)})
	}
	return spans
}

func validPoint(point HourPoint) bool {
	return point.Day >= 0 && point.Day <= 6 && point.Hour >= 0 && point.Hour <= 24 && point.Minute >= 0 && point.Minute <= 59
}
