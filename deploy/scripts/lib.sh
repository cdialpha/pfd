#!/usr/bin/env bash

[[ "${BASH_SOURCE[0]}" != "$0" ]] || { echo "lib.sh must be sourced" >&2; exit 1; }

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
DEPLOY_DIR="$PWD" 

# SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
# cd "$PROJECT_ROOT"
# echo "pwd: $(pwd), script dir: $SCRIPT_DIR, project root: $PROJECT_ROOT"

PROJECT="${PROJECT:-$(basename "PROJECT_ROOT")}"
LABEL_KEY="pfd.com"
LABEL="${LABEL_KEY}=${PROJECT}"

export CLUSTER_NAME="${CLUSTER_NAME:-dev}"
export K8S_VERSION="${K8S_VERSION:-v1.31.0}"
export KIND_NET="${KIND_NET:-kind}" 
export KIND_SUBNET="${KIND_SUBNET:-172.20.0.0/16}" 
export KIND_GW="${KIND_GW:-172.20.0.1}" 
export CP_IP="${CP_IP:-172.20.0.2}" 

ok()   { echo "✓ $*" >&2; }
warn() { echo "! $*" >&2; }
die()  { echo "✗ $*" >&2; exit 1; }

# env vars - load from .env or .env.example if exists, don't fail if missing
load_env() {
  [[ "${ENV_LOADED:-}" == 1 ]] && return 0
  local f="$PROJECT_ROOT/.env"
  if [[ ! -f "$f" ]]; then
    f="$PROJECT_ROOT/.env.example"
    [[ -f "$f" ]] || die "no .env or .env.example in $PROJECT_ROOT"
    warn "using .env.example - copy to .env to customize"
  fi
  set -a
  # shellcheck source=/dev/null
  source "$f"
  set +a
  export ENV_LOADED=1
}

# retry TRIES SLEEP_S CMD... - rerun CMD until success
retry() {
  local n=$1 s=$2 i
  shift 2
  for ((i = 1; i <= n; i++)); do
    "$@" && return 0
    ((i < n)) && sleep "$s"
  done
  return 1
}

# Always target the kind context - never whatever is current.
kc() { kubectl --context "kind-$CLUSTER_NAME" "$@"; }
hc() { helm --kube-context "kind-$CLUSTER_NAME" "$@"; }
 

# require cluster to exist (e.g. for teardown)
# require_cluster() {
#   kind get clusters 2>/dev/null | grep -qx -- "${CLUSTER_NAME}" || \
#   die() { printf 'Error: %s\n' "$*" >&2; exit 1; }
# }
cluster_exists() { kind get clusters 2>/dev/null | grep -qx "$CLUSTER_NAME"; }
