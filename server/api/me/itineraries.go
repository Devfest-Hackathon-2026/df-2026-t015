package me

import (
	"net/http"
	"strconv"

	"github.com/create-alt/gen-TLE/server/internal/service"
)

// Itineraries は GET /me/itineraries（F-08）。本人の旅程を旅行日の新しい順に limit 件ずつ返す。
func Itineraries(app *service.App) http.HandlerFunc {
	return service.Handle(func(w http.ResponseWriter, r *http.Request) error {
		query := r.URL.Query()
		limit := 20
		if query.Has("limit") {
			value, err := strconv.Atoi(query.Get("limit"))
			if err != nil || value < 1 || value > 50 {
				return service.Invalid("limit は1〜50で指定してください")
			}
			limit = value
		}
		cursor := query.Get("cursor")
		if query.Has("cursor") && !service.Text(cursor, 1, 500) {
			return service.Invalid("cursor が不正です")
		}
		page, err := app.Store.List(r.Context(), service.UID(r), limit, cursor)
		if err != nil {
			return err
		}
		service.JSON(w, 200, page)
		return nil
	})
}
