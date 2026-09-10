package accounts

import (
	"context"
	"errors"
	"fmt"
	"net"
	"net/url"

	"github.com/cdialpha/pfd/accounts/internal/config"
	"github.com/jackc/pgx/v5/pgxpool"
)

var (
	ErrNotFound        = errors.New("account not found")
	ErrDeuplicateEmail = errors.New("email already registered")
)

type Store struct{ Pool *pgxpool.Pool }

func (s *Store) Close() {
	s.Pool.Close()
}

func (s *Store) GetByID(ctx context.Context, id int64) (Account, error) {
	// logic
	a := Account{}
	return a, nil
}

func (s *Store) Create(ctx context.Context, a Account) (Account, error) {
	// 1. Insert account into DB (e.g. using pgxpool)
	// 2. Return created Account struct or error

	// 1. Hash PW (e.g. using argon2id)
	// 2. Call s.repo.CreateAccount(...)
	// 3. Return created Account or error

	return a, nil
}

// func (s *Store)  ErrDuplicateEmail

func NewStore(ctx context.Context, cfg config.Config) (*Store, error) {
	q := url.Values{}
	q.Set("sslmode", cfg.SSLMode)
	q.Set("sslcert", cfg.TLSClientCert)
	q.Set("sslkey", cfg.TLSClientKey)
	q.Set("sslrootcert", cfg.TLSRootCert)

	dsn := url.URL{
		Scheme:   "postgres",
		User:     url.User(cfg.DBUser),
		Host:     net.JoinHostPort(cfg.DBHost, cfg.DBPort),
		Path:     "/" + cfg.DBName,
		RawQuery: q.Encode(),
	}

	poolCfg, err := pgxpool.ParseConfig(dsn.String())
	if err != nil {
		return nil, fmt.Errorf("parsing pool config: %w", err)
	}

	pool, err := pgxpool.NewWithConfig(ctx, poolCfg)
	if err != nil {
		return nil, fmt.Errorf("creating pool: %w", err)
	}

	pingCtx, cancel := context.WithTimeout(ctx, cfg.ReadTimeout)
	defer cancel()
	if err := pool.Ping(pingCtx); err != nil {
		pool.Close()
		return nil, fmt.Errorf("pinging db: %w", err)
	}

	return &Store{Pool: pool}, nil

}

type Account struct {
	Id    string
	Name  string
	Email string
}

// type AccountRepository interface {
// 	CreateAccount(ctx context.Context, email string, passwordHash string) (*Account, error)
// }

// type Service struct {
// 	repo AccountRepository
// }

// func NewService(repo AccountRepository) *Service {
// 	return &Service{repo: repo}
// }
