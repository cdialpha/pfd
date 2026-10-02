#!/usr/bin/env bash
# status.sh - R-only summary. No -e: report every layer even if some are absent.
set -uo pipefail
# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
load_env

hdr() { printf '\n== %s\n' "$*"; }

hdr "network"
docker network inspect -f '{{.Name}} {{ (index .IPAM.Config 0).Subnet }}' "$KIND_NET" 2>/dev/null \
  || echo "absent"

hdr "db"
docker compose -f "$DEPLOY_DIR/db/docker-compose.yaml" ps

hdr "certs"
for c in "$TLS_DIR/ca/ca.crt" "$TLS_DIR/server/tls.crt"; do
  if [[ -f "$c" ]]; then
    printf '%s  ' "${c#"$PROJECT_ROOT"/}"
    openssl x509 -in "$c" -noout -enddate
  else
    echo "${c#"$PROJECT_ROOT"/} absent"
  fi
done

hdr "cluster"
if cluster_exists; then
  kc get nodes -o wide
  hdr "cilium"
  cilium status --context "kind-$CLUSTER_NAME" 2>/dev/null | head -20
  hdr "argocd apps"
  kc -n argocd get applications 2>/dev/null || echo "argocd not installed"
else
  echo "absent"
fi