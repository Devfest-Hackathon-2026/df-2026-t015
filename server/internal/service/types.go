package service

import (
	"context"
	"time"
)

type Point struct {
	Lat float64 `json:"lat"`
	Lng float64 `json:"lng"`
}

type Place struct {
	PlaceID  string `json:"placeId"`
	Name     string `json:"name"`
	Address  string `json:"address"`
	Location Point  `json:"location"`
	Hours    *Hours `json:"-"`
}

type Price struct {
	Amount *int   `json:"amount"`
	Kind   string `json:"kind"`
	Source string `json:"source,omitempty"`
}

type OpeningHours struct {
	OpensAt  string `json:"opensAt"`
	ClosesAt string `json:"closesAt"`
}

type Item struct {
	ItemID       string        `json:"itemId"`
	PlaceID      string        `json:"placeId"`
	Name         string        `json:"name"`
	Priority     string        `json:"priority"`
	StayMin      int           `json:"stayMin"`
	StartAt      string        `json:"startAt"`
	EndAt        string        `json:"endAt"`
	Price        Price         `json:"price"`
	OpeningHours *OpeningHours `json:"openingHours"`
	Status       string        `json:"status"`
}

type Leg struct {
	FromItemID  string  `json:"fromItemId"`
	ToItemID    string  `json:"toItemId"`
	Mode        string  `json:"mode"`
	DurationMin int     `json:"durationMin"`
	DepartAt    string  `json:"departAt"`
	ArriveAt    string  `json:"arriveAt"`
	LineName    *string `json:"lineName"`
}

type Summary struct {
	MoveMin    int `json:"moveMin"`
	PriceTotal struct {
		Amount      int  `json:"amount"`
		HasEstimate bool `json:"hasEstimate"`
	} `json:"priceTotal"`
	EndAt string `json:"endAt"`
}

// Start は出発地と出発時刻（Endpoint ＋ departAt）。
// 地図で施設ではない地点を選んだときは PlaceID が nil で、Location と Name を持つ。
// 入力の departAt は HH:mm、出力は日時。
type Start struct {
	PlaceID  *string `json:"placeId"`
	Name     string  `json:"name"`
	Location *Point  `json:"location,omitempty"`
	DepartAt string  `json:"departAt"`
}

// End は終わる場所と時刻（Endpoint ＋ arriveBy, arriveAt）。
// arriveBy は着きたい時刻（HH:mm）、arriveAt は着く予定の日時（出力のみ）。
type End struct {
	PlaceID  *string `json:"placeId"`
	Name     string  `json:"name"`
	Location *Point  `json:"location,omitempty"`
	ArriveBy string  `json:"arriveBy"`
	ArriveAt string  `json:"arriveAt,omitempty"`
}

// Waypoint は経路計算に渡す地点。施設なら PlaceID、それ以外は Location を使う。
type Waypoint struct {
	PlaceID  string
	Location Point
}

func pointWaypoint(id *string, location *Point) Waypoint {
	if id != nil && *id != "" {
		return Waypoint{PlaceID: *id}
	}
	if location != nil {
		return Waypoint{Location: *location}
	}
	return Waypoint{}
}

func (s Start) Waypoint() Waypoint { return pointWaypoint(s.PlaceID, s.Location) }
func (e End) Waypoint() Waypoint   { return pointWaypoint(e.PlaceID, e.Location) }

type Dropped struct {
	PlaceID string `json:"placeId"`
	Name    string `json:"name"`
	Reason  string `json:"reason"`
}

type Itinerary struct {
	ID        string    `json:"id"`
	Version   int       `json:"version"`
	Title     string    `json:"title"`
	Date      string    `json:"date"`
	Start     Start     `json:"start"`
	End       End       `json:"end"`
	Items     []Item    `json:"items"`
	Legs      []Leg     `json:"legs"`
	Summary   Summary   `json:"summary"`
	Dropped   []Dropped `json:"dropped"`
	ExpiresAt string    `json:"expiresAt"`
}

type Visit struct {
	PlaceID  string `json:"placeId"`
	Priority string `json:"priority"`
	StayMin  int    `json:"stayMin"`
}

type PlanInput struct {
	Title  string  `json:"title"`
	Date   string  `json:"date"`
	Start  Start   `json:"start"`
	End    End     `json:"end"`
	Places []Visit `json:"places"`
}

// EditInput は PUT /itineraries/:id/places の入力。date・start・end は省略すると今の値のまま。
type EditInput struct {
	Date   *string `json:"date"`
	Start  *Start  `json:"start"`
	End    *End    `json:"end"`
	Places []Visit `json:"places"`
}

type EntryStart struct {
	Name     string `json:"name"`
	DepartAt string `json:"departAt"`
}

type EntryEnd struct {
	Name     string `json:"name"`
	ArriveAt string `json:"arriveAt"`
}

// ItineraryEntry は GET /me/itineraries の1件。
type ItineraryEntry struct {
	ID         string     `json:"id"`
	Title      string     `json:"title"`
	Date       string     `json:"date"`
	Start      EntryStart `json:"start"`
	End        EntryEnd   `json:"end"`
	PlaceCount int        `json:"placeCount"`
	PlaceNames []string   `json:"placeNames"`
	UpdatedAt  string     `json:"updatedAt"`
	ExpiresAt  string     `json:"expiresAt"`
}

type ItineraryPage struct {
	Itineraries []ItineraryEntry `json:"itineraries"`
	NextCursor  *string          `json:"nextCursor"`
}

type Change struct {
	Type   string `json:"type"`
	ItemID string `json:"itemId"`
	Before *Item  `json:"before,omitempty"`
	After  *Item  `json:"after,omitempty"`
	Note   string `json:"note,omitempty"`
}

type Preview struct {
	Items []Item `json:"items"`
	Legs  []Leg  `json:"legs"`
}

type Option struct {
	OptionID      string    `json:"optionId"`
	Changes       []Change  `json:"changes"`
	SummaryBefore Summary   `json:"summaryBefore"`
	SummaryAfter  Summary   `json:"summaryAfter"`
	Preview       Preview   `json:"preview"`
	Candidate     Itinerary `json:"-"`
}

type Warning struct {
	Type    string `json:"type"`
	ItemID  string `json:"itemId"`
	Message string `json:"message"`
}

type Explanation struct {
	Status     string    `json:"status"`
	Text       string    `json:"text,omitempty"`
	Lease      string    `json:"-"`
	LeaseUntil time.Time `json:"-"`
}

type Replan struct {
	ReplanID       string                 `json:"replanId,omitempty"`
	ItineraryID    string                 `json:"-"`
	BasedOnVersion int                    `json:"basedOnVersion,omitempty"`
	NeedsChange    bool                   `json:"needsChange"`
	ExpiresAt      string                 `json:"expiresAt,omitempty"`
	Warnings       []Warning              `json:"warnings"`
	Options        []Option               `json:"options"`
	Explanation    Explanation            `json:"explanation,omitempty"`
	Explanations   map[string]Explanation `json:"-"`
}

type ReplanInput struct {
	CurrentItemID string `json:"currentItemId"`
	DelayMin      *int   `json:"delayMin,omitempty"`
	Now           string `json:"now,omitempty"`
}

type Store interface {
	Create(context.Context, string, *Itinerary) error
	Get(context.Context, string, string) (Itinerary, error)
	List(context.Context, string, int, string) (ItineraryPage, error)
	Count(context.Context, string) (int, error)
	Update(context.Context, string, string, int, *Itinerary) error
	SaveReplan(context.Context, string, *Replan) error
	GetReplan(context.Context, string, string, string) (Replan, error)
	Accept(context.Context, string, string, string, string, int) (Itinerary, error)
	ClaimExplanation(context.Context, string, string, string, string) (Explanation, bool, error)
	FinishExplanation(context.Context, string, string, string, string, string, Explanation) error
	Allow(context.Context, string) error
}

type App struct {
	Verify func(context.Context, string) (string, error)
	Store  Store
	Maps   *Maps
	AI     *Gemini
}
