package server

import (
	"context"
	"errors"
	"io"
	"log/slog"
	"net/http"
	"net/mail"
	"strings"
	"sync/atomic"

	"github.com/cdialpha/pfd/accounts/internal/accounts"
)

func handleGetAccount(logger *slog.Logger) http.Handler {
	// one time setup (e.g. compiled regex, templates, etc.)
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {

		id := r.PathValue("id")
		_ = encode(w, r, http.StatusOK, map[string]string{"id": id})
	})
}

func (req getAccountReq) Valid(ctx context.Context) (problems map[string]string) {
	problems = map[string]string{}
	if req.Name == "" {
		problems["name"] = "requried"
	}
	return problems
}

func handleHealth() http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Cache-Control", "no-store")
		w.Header().Set("Content-Type", "text/plain; charset=utf-8")
		w.WriteHeader(http.StatusOK)
		io.WriteString(w, "ok\n")
	})
}

func handleReady(logger *slog.Logger, ready *Ready) http.Handler {
	log := logger.With("handler", "handleReadyz")
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Cache-Control", "no-store")
		switch {
		case ready.Draining.Load():
			http.Error(w, "draining", http.StatusServiceUnavailable)
		case !ready.Connected.Load():
			log.WarnContext(r.Context(), "not ready", "reason", "pool never established")
			http.Error(w, "starting", http.StatusServiceUnavailable)
		default:
			w.WriteHeader(http.StatusOK)
			io.WriteString(w, "ready\n")
		}
	})
}

type Ready struct {
	Draining  atomic.Bool // flipped on SIGTERM
	Connected atomic.Bool // flipped once, after 1st successful ping at boot
}

type createAccountRequest struct {
	Name  string `json:"name"`
	Email string `json:"email"`
}

type createAccountResponse struct {
	ID    string `json:"id"`
	Name  string `json:"name"`
	Email string `json:"email"`
}

type getAccountReq struct {
	Name string `json:"name"`
}

type AccountCreator interface {
	CreateAccount(ctx context.Context, name, email string) (accounts.Account, error)
}

func (req createAccountRequest) Valid(ctx context.Context) (problems map[string]string) {
	problems = map[string]string{}
	if strings.TrimSpace(req.Name) == "" {
		problems["name"] = "required"
	}
	if _, err := mail.ParseAddress(req.Email); err != nil {
		problems["mail"] = "must be valid email adddress"
	}
	return problems
}

func handleCreateAccount(logger *slog.Logger, accounts AccountCreator) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		ctx := r.Context()
		r.Body = http.MaxBytesReader(w, r.Body, 1<<20) // cap body @ 1MB
		req, problems, err := decodeValid[createAccountRequest](r)
		if len(problems) > 0 { // check problems 1st - err is always non-nil
			_ = encode(w, r, http.StatusBadRequest, problems)
			return
		}
		if err != nil {
			logger.DebugContext(ctx, "malformed body", "err", err)
			http.Error(w, "invalid request body", http.StatusBadRequest)
			return
		}
		account, err := accounts.CreateAccount(ctx, req.Name, req.Email)
		switch {
		case errors.Is(err, accounts.ErrDuplicateEmail):
			_ = encode(w, r, http.StatusConflict, map[string]string{"email": "already registered"})
			return
		case err != nil:
			logger.ErrorContext(ctx, "create account", "err", err)
			http.Error(w, "internal server error", http.StatusInternalServerError)
			return
		}
		if err := encode(w, r, http.StatusCreated, createAccountResponse{
			ID: account.ID, Name: account.Name, Email: account.Email,
		}); err != nil {
			logger.ErrorContext(ctx, "encode response", "err", err)
		}
	})
}
