#!/usr/bin/env bash

set -eo pipefail # exit on error, and fail if any command in a pipeline fails

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"
# echo "pwd: $(pwd), script dir: $SCRIPT_DIR, project root: $PROJECT_ROOT"

# env vars - load from .env or .env.example if exists, don't fail if missing
load_env() {
    if [[ -f .env ]]; then
        echo "Loading env vars from .env file"
        source .env 
    elif [[ -f .env.example ]]; then
        echo "No .env file found, loading from .env.example"
        source .env.example
    else # fallback to defaults if not set
        echo "No .env or .env.example file found, using defaults"
    fi
}

export CLUSTER_NAME="${CLUSTER_NAME:-dev}"
export K8S_VERSION="${K8S_VERSION:-v1.31.0}"
set -u # enforce unset variables as an error

die() { printf 'Error: %s\n' "$*" >&2; exit 1; }

require() {
    local missing=() 
    local cmd 
    for cmd in "$@"; do 
      command -v -- "$cmd" &> /dev/null || missing+=("$cmd")
    done
    if ((${#missing[@]} > 0 )); then
        die "missing required dep(s): ${missing[*]}"
    fi 
}

# TO DO? Add manifests/bootstrap charts/myapp
check_files() {
    local files=(cluster-config.yaml)
    for file in "${files[@]}"; do
        if [ ! -e "$file" ]; then
            echo "Error: Required file or directory '$file' is missing." >&2
            exit 1
        fi
    done
}

# require cluster to exist (e.g. for teardown)
require_cluster() {
  kind get clusters 2>/dev/null | grep -qx -- "${CLUSTER_NAME}" || \
  die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
}

