package server

import (
	"log/slog"
	"net/http"
	"time"

	"github.com/cdialpha/pfd/accounts/internal/config"
)

func addRoutes(
	mux *http.ServeMux,
	logger *slog.Logger,
	cfg config.Config,
	accountStore accountStore,
) {
	mux.Handle("GET /healthz", handleHealth(logger))
	mux.Handle("GET /readyz", handleReady(logger))
	mux.Handle("GET /accounts/v1/{id}", handleGetAccount(logger))
	mux.Handle("/", http.NotFoundHandler())
	// add routes
}

type statusWriter struct {
	http.ResponseWriter
	status int
}

func (sw *statusWriter) WriteHeader(code int) {
	sw.status = code
	sw.ResponseWriter.WriteHeader(code)
}

func reqAttrs(r *http.Request) slog.Attr {
	return slog.Group("req",
		slog.String("method", r.Method),
		slog.String("path", r.URL.Path),
		slog.String("remote_addr", r.RemoteAddr),
	)
}

func respAttrs(status int, dur time.Duration) slog.Attr {
	return slog.Group("resp",
		slog.Int("status", status),
		slog.Int64("duration_ms", dur.Milliseconds()),
	)
}

func NewLoggingMiddleware(logger *slog.Logger) func(http.Handler) http.Handler {
	return func(next http.Handler) http.Handler {
		return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
			start := time.Now()
			rec := &statusWriter{ResponseWriter: w, status: 200}
			next.ServeHTTP(rec, r)
			logger.LogAttrs(r.Context(), slog.LevelInfo, "http_req",
				reqAttrs(r),
				respAttrs(rec.status, time.Since(start)),
			)
		})
	}
}
