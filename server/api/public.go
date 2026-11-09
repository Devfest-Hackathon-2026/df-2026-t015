package api

import (
	"net/http"
	"net/url"
	"os"
	"strings"
)

// PublicOptions は公開時の設定。
type PublicOptions struct {
	// BasePath は API の前に付くパス（例: "/api"）。Firebase Hosting の rewrite で
	// /api/** を Cloud Run に転送すると、サーバーには /api/places/... のように届くため、
	// これを取り除いてからルーティングする。前置きのないリクエストもそのまま受け付ける。
	BasePath string
	// AllowedOrigins は CORS を許可するオリジン。"https://example.web.app" のような完全一致か、
	// "http://localhost:*" のようにポートだけを任意にした指定ができる。空なら CORS を使わない。
	AllowedOrigins []string
}

// PublicOptionsFromEnv は API_BASE_PATH と CORS_ALLOWED_ORIGINS（カンマ区切り）から設定を読む。
func PublicOptionsFromEnv() PublicOptions {
	options := PublicOptions{BasePath: strings.TrimRight(strings.TrimSpace(os.Getenv("API_BASE_PATH")), "/")}
	for _, origin := range strings.Split(os.Getenv("CORS_ALLOWED_ORIGINS"), ",") {
		if origin = strings.TrimRight(strings.TrimSpace(origin), "/"); origin != "" {
			options.AllowedOrigins = append(options.AllowedOrigins, origin)
		}
	}
	return options
}

// Public は API のハンドラーに、公開時に必要な前置きの除去と CORS を足す。
func Public(next http.Handler, options PublicOptions) http.Handler {
	return cors(stripBasePath(next, options.BasePath), options.AllowedOrigins)
}

func stripBasePath(next http.Handler, base string) http.Handler {
	if base == "" || base == "/" {
		return next
	}
	if !strings.HasPrefix(base, "/") {
		base = "/" + base
	}
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		path := r.URL.Path
		if path != base && !strings.HasPrefix(path, base+"/") {
			next.ServeHTTP(w, r)
			return
		}
		stripped := r.Clone(r.Context())
		stripped.URL.Path = strings.TrimPrefix(path, base)
		if stripped.URL.Path == "" {
			stripped.URL.Path = "/"
		}
		if r.URL.RawPath != "" {
			stripped.URL.RawPath = strings.TrimPrefix(r.URL.RawPath, base)
		}
		next.ServeHTTP(w, stripped)
	})
}

func originAllowed(origin string, allowed []string) bool {
	for _, pattern := range allowed {
		if pattern == origin {
			return true
		}
		// "http://localhost:*" は http://localhost の任意のポートを許可する（flutter run の開発用サーバー向け）。
		if prefix, ok := strings.CutSuffix(pattern, ":*"); ok {
			parsed, err := url.Parse(origin)
			if err == nil && parsed.Scheme+"://"+parsed.Hostname() == prefix {
				return true
			}
		}
	}
	return false
}

func cors(next http.Handler, allowed []string) http.Handler {
	if len(allowed) == 0 {
		return next
	}
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		origin := r.Header.Get("Origin")
		if origin == "" || !originAllowed(origin, allowed) {
			next.ServeHTTP(w, r)
			return
		}
		header := w.Header()
		header.Set("Access-Control-Allow-Origin", origin)
		header.Add("Vary", "Origin")
		header.Set("Access-Control-Expose-Headers", "ETag, Retry-After")
		// プリフライトは認証の前に答える（ブラウザは Authorization を付けずに送るため）。
		if r.Method == http.MethodOptions && r.Header.Get("Access-Control-Request-Method") != "" {
			header.Set("Access-Control-Allow-Methods", "GET, POST, PUT, PATCH, DELETE")
			header.Set("Access-Control-Allow-Headers", "Authorization, Content-Type, If-Match")
			header.Set("Access-Control-Max-Age", "600")
			w.WriteHeader(http.StatusNoContent)
			return
		}
		next.ServeHTTP(w, r)
	})
}
