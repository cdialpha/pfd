package main

import (
	"context"
	"log"
	"net"

	pb "github.com/cdialpha/pfd/internal/gen/accounts/v1" // Protobuf generated code package

	"github.com/cdialpha/pfd/internal/accounts"
	"github.com/cdialpha/pfd/internal/config"
	"github.com/jackc/pgx/v5/pgxpool"
	"google.golang.org/grpc"
)

func main() {
	cfg := config.Load()
	ctx := context.Background()

	pool, err := pgxpool.New(ctx, cfg.DBURL)
	if err != nil {
		log.Fatalf("Unable to connect to database: %v", err)
	}
	defer pool.Close()

	repo := accounts.NewRepository(pool) // returns &Repository{db: db}
	svc := accounts.NewService(repo)     // returns &Service{repo: repo}
	grpcHandler := accounts.NewGRPCHandler(svc)

	s := grpc.NewServer()
	pb.RegisterAccountsServiceServer(s, grpcHandler) //&server{db: pool}

	// TO DO: Add Health Check Endpoint (e.g., using gRPC Health Checking Protocol)
	// TO DO: Implement structured logging (e.g., using logrus or zap) for better observability

	// 5. Start gRPC server in a goroutine and handle potential startup errors
	lis, err := net.Listen("tcp", ":50051")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}
	log.Printf("gRPC server listening on %s", lis.Addr().String())

	ServerErr := make(chan error, 1)
	go func() {
		if err := s.Serve(lis); err != nil && err != grpc.ErrServerStopped {
			ServerErr <- err
		}
	}()

	// 4. Handle graceful shutdown signals in a goroutine
	select {
	case err := <-ServerErr:
		log.Fatalf("Error starting gRPC server: %v", err)
	case <-ctx.Done():
		log.Println("Shutting down gRPC server...")
		s.GracefulStop()
		log.Println("gRPC server stopped gracefully")
	}
}

// 	type server struct {
// 	pb.UnimplementedAccountsServiceServer
// 	db *pgxpool.Pool
// }
