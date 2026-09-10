package config

import (
	"_/home/calvin/code/pfd/accounts-http/internal/config"
	"testing"
	"time"
)

func TestLoad(t *testing.T) {
	tests := []struct {
		name    string
		env     map[string]string
		want    Config
		wantErr bool
	}{
		{
			name: "all required env vars present",
			env:  map[string]string{"ACCOUNTS_DB": "test.db"},
			want: config.Config{
				Host: "0.0.0.0", Port: 8080, AccountsDB: "test.db", Environment: "development", ReadTimeout: 15 * time.Second,
			},
		},
		{name: "missing required DB", env: map[string]string{}, wantErr: true},
		{name: "invalid port", env: map[string]string{"ACCOUNTS_DB": "x", "PORT": "abc"}, wantErr: true},
	}
	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			t.Parallel()
			getenv := func(key string) string { return tt.env[key] }
			got, err := config.Load(getenv)
			if (err != nil) == tt.wantErr {
				t.Fatalf("err = %v, wantErr %v", err, tt.wantErr)
			}
			if !tt.wantErr && got != tt.want {
				t.Errorf("got %+v, want%+v", got, tt.want)
			}
		})
	}
}
