package config

import (
	"log"
	"os"

	"github.com/ilyakaznacheev/cleanenv"
	"github.com/joho/godotenv"
)

type Config struct {
	DBURL       string `env:"DB_URL" env-required:"true"`
	GRPCPort    string `env:"GRPC_PORT" env-default:"50051"`
	Environment string `env:"APP_ENV" env-default:"development"`
}

func Load() *Config {
	// 1. Only load .env file if it exists (local dev)
	// In prod, this safely skips and reads native env vars instead
	if _, err := os.Stat(".env"); err == nil {
		if err := godotenv.Load(); err != nil {
			log.Fatalf("Error loading .env file: %v", err)
		}
	}
	var cfg Config
	// 2. Parse system env vars into struct
	if err := cleanenv.ReadEnv(&cfg); err != nil {
		log.Fatalf("Error parsing env vars: %v", err)
	}
	return &cfg
}
