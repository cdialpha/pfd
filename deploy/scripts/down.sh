#!/usr/bin/env bash
# down.sh - teardown (idempotent). Keeps certs; PURGE=1 also removes net + db volumes.
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
load_env

if cluster_exists; then
  kind delete cluster --name "$CLUSTER_NAME"
else
  ok "no cluster $CLUSTER_NAME"
fi

compose=(docker compose -f "$DEPLOY_DIR/db/docker-compose.yaml")
if [[ "${PURGE:-0}" == 1 ]]; then
  "${compose[@]}" down -v
  # net last - must have no attached containers
  if docker network inspect "$KIND_NET" >/dev/null 2>&1; then
    docker network rm "$KIND_NET" >/dev/null && ok "removed network $KIND_NET"
  fi
else
  "${compose[@]}" down
fi
ok "down"