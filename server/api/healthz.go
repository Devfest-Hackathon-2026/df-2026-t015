package api

import (
	"net/http"

	"github.com/create-alt/gen-TLE/server/internal/service"
)

func Healthz(w http.ResponseWriter, r *http.Request) {
	service.JSON(w, 200, map[string]string{"status": "ok"})
}
