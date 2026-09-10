package server

import (
	"context"
	"fmt"
	"io"
	"log/slog"
	"net"
	"net/http"
	"os"
	"os/signal"
	"sync"
	"time"

	"github.com/cdialpha/pfd/accounts/internal/accounts"
	"github.com/cdialpha/pfd/accounts/internal/config"
)

func Run(
	ctx context.Context,
	args []string,
	getenv func(string) string,
	stdin io.Reader,
	stdout,
	stderr io.Writer,
) error {
	ctx, cancel := signal.NotifyContext(ctx, os.Interrupt)
	defer cancel()

	cfg, err := config.Load(getenv)
	if err != nil {
		return err
	}

	logger := slog.New(slog.NewJSONHandler(stdout, nil))

	acctStore, err := accounts.NewStore(ctx, cfg)
	if err != nil {
		return err
	}

	srv := NewServer(logger, cfg, acctStore)

	httpServer := &http.Server{
		Addr:              net.JoinHostPort(cfg.Host, cfg.Port),
		Handler:           srv,
		ReadHeaderTimeout: 5 * time.Second,
		ReadTimeout:       15 * time.Second,
		WriteTimeout:      30 * time.Second,
		IdleTimeout:       120 * time.Second,
		MaxHeaderBytes:    1 << 16,
	}

	go func() {
		logger.Info("listening on " + httpServer.Addr)
		if err := httpServer.ListenAndServe(); err != nil && err != http.ErrServerClosed {
			fmt.Printf("could not listen on %s: %v\n", httpServer.Addr, err)
		}
	}()
	wg := sync.WaitGroup{}
	wg.Add(1)

	go func() {
		defer wg.Done()
		<-ctx.Done()
		shutdownCtx := context.Background()
		shutdownCtx, cancel := context.WithTimeout(shutdownCtx, 10*time.Second)
		defer cancel()
		if err := httpServer.Shutdown(shutdownCtx); err != nil {
			fmt.Fprintf(stderr, "HTTP server Shutdown: %v\n", err)
		}
	}()
	wg.Wait()
	return nil

}

func NewServer(
	logger *slog.Logger,
	cfg config.Config,
	accountStore accountStore,
) http.Handler {
	mux := http.NewServeMux()
	addRoutes(mux, logger, cfg, accountStore)
	var handler http.Handler = mux
	logmw := NewLoggingMiddleware(logger)
	handler = logmw(handler)
	// handler = recoveryMiddleware(logger, handler)
	return handler
}

type accountStore interface {
	Create(context.Context, accounts.Account) (accounts.Account, error)
	GetByID(context.Context, int64) (accounts.Account, error)
}
