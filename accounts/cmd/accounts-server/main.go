package main

import (
	"context"
	"fmt"
	"os"

	"github.com/cdialpha/pfd/accounts/internal/server"
)

func main() {
	ctx := context.Background()

	if err := server.Run(ctx, os.Args, os.Getenv, os.Stdin, os.Stdout, os.Stderr); err != nil {
		fmt.Fprint(os.Stderr, "%s\n", err)
		os.Exit(1)
		// ..
	}

}
