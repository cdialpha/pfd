package accounts

import (
	"context"

	accountsv1 "github.com/cdialpha/pfd/internal/gen/accounts/v1"
)

type DomainService interface {
	CreateAccount(ctx context.Context, email string, name string) (*Account, error)
}

type GRPCHandler struct {
	accountsv1.UnimplementedAccountsServiceServer
	Service DomainService
}

// Constructor function enforces dependency injection
func NewGRPCHandler(service DomainService) *GRPCHandler {
	return &GRPCHandler{Service: service}
}

var _ accountsv1.AccountsServiceServer = (*GRPCHandler)(nil)

// gRPC endpoint handler implementation
func (h *GRPCHandler) CreateAccount(ctx context.Context, req *accountsv1.CreateAccountRequest) (*accountsv1.CreateAccountResponse, error) {
	acc, err := h.Service.CreateAccount(ctx, req.Email, req.Name)
	if err != nil {
		return nil, err
	}
	// Map domain entity to protobuf wire-format response
	return &accountsv1.CreateAccountResponse{
		Account: &accountsv1.Account{
			Id:    acc.Id,
			Name:  acc.Name,
			Email: acc.Email,
		},
	}, nil
}
