package accounts

import (
	"context"

	"github.com/jackc/pgx/v5/pgxpool"
)

type Repository struct {
	db *pgxpool.Pool
}

func NewRepository(db *pgxpool.Pool) *Repository {
	return &Repository{db: db}
}

func (r *Repository) CreateAccount(ctx context.Context, email string, passwordHash string) (*Account, error) {
	// 1. Insert account into DB (e.g. using pgxpool)
	// 2. Return created Account struct or error

	return &Account{Id: "generated-id", Email: email}, nil
}
