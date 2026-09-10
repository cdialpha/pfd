package config

import (
	"errors"
	"fmt"
	"strconv"
	"time"
)

type Config struct {
	Env, Host, Port, DBName, DBUser, DBHost, DBPort, SSLMode, TLSClientKey, TLSClientCert, TLSRootCert string
	ReadTimeout                                                                                        time.Duration
}

// TO DO: add defaults

func Load(getenv func(string) string) (Config, error) {
	l := loader{getenv: getenv}
	cfg := Config{
		Env:           l.str("APP_ENV", "dev", optional),
		Host:          l.str("HOST", "0.0.0.0", optional),
		Port:          l.str("HTTP_PORT", "8080", optional),
		DBName:        l.str("ACCOUNTS_DB", "", required),
		DBUser:        l.str("DB_USER", "pgadmin", required),
		DBHost:        l.str("DB_HOST", "0.0.0.0", required),
		DBPort:        l.str("DB_PORT", "5432", optional),
		SSLMode:       l.str("SSL_MODE", "enabled", optional),
		TLSClientKey:  l.str("SSL_CLIENT_KEY", "", optional),
		TLSClientCert: l.str("SSL_CLIENT_CERT", "", optional),
		TLSRootCert:   l.str("SSL_ROOT_CERT", "", optional),
		ReadTimeout:   l.dur("READ_TIMEOUT", 30*time.Second, optional),
	}
	if err := errors.Join(l.errs...); err != nil {
		return Config{}, fmt.Errorf("load config: %w", err)
	}
	return cfg, nil
}

const (
	required = true
	optional = false
)

type loader struct {
	getenv func(string) string
	errs   []error
}

func (l *loader) str(key string, def string, req bool) string {
	v := l.getenv(key)
	if v == "" {
		if req {
			l.errs = append(l.errs, fmt.Errorf("%s if requred", key))
		}
		return def
	}
	return v
}

func (l *loader) int(key string, def int, req bool) int {
	raw := l.getenv(key)
	if raw == "" {
		if req {
			l.errs = append(l.errs, fmt.Errorf("%s is required", key))
		}
		return def
	}
	i, err := strconv.Atoi(raw)
	if err != nil {
		l.errs = append(l.errs, fmt.Errorf("%s must be an int, got %q", key, raw))
		return def
	}
	return i
}

func (l *loader) dur(key string, def time.Duration, req bool) time.Duration {
	raw := l.getenv(key)
	if raw == "" {
		if req {
			l.errs = append(l.errs, fmt.Errorf("%s is required", key))
		}
		return def
	}
	d, err := time.ParseDuration(raw)
	if err != nil {
		l.errs = append(l.errs, fmt.Errorf("%s must be a duration, got %q", key, raw))
		return def
	}
	return d
}
