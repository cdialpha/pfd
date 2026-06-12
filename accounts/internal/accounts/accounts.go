package accounts

import "context"

type Account struct {
	Id    string
	Name  string
	Email string
}

type AccountRepository interface {
	CreateAccount(ctx context.Context, email string, passwordHash string) (*Account, error)
}

type Service struct {
	repo AccountRepository
}

func NewService(repo AccountRepository) *Service {
	return &Service{repo: repo}
}

// Business logic
func (s *Service) CreateAccount(ctx context.Context, email string, password string) (*Account, error) {
	// 1. Hash PW (e.g. using argon2id)
	// 2. Call s.repo.CreateAccount(...)
	// 3. Return created Account or error

	return &Account{Id: "generated-id", Email: email}, nil
}
