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

type Start struct {
	PlaceID  string `json:"placeId"`
	Name     string `json:"name,omitempty"`
	DepartAt string `json:"departAt"`
}

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
	EndBy     string    `json:"endBy"`
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
	EndBy  string  `json:"endBy"`
	Places []Visit `json:"places"`
}

type ItineraryEntry struct {
	ID        string `json:"id"`
	Title     string `json:"title"`
	Date      string `json:"date"`
	UpdatedAt string `json:"updatedAt"`
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
	List(context.Context, string) ([]ItineraryEntry, error)
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
