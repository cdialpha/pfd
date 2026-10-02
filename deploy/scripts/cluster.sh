#!/usr/bin/env bash
# cluster.sh - kind cluster on the pinned net (idempotent). Nodes stay NotReady until CNI.
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
load_env

if cluster_exists; then
  ok "cluster $CLUSTER_NAME exists"
else
    kind create cluster --name "$CLUSTER_NAME" --config "$DEPLOY_DIR/cluster-config.yaml"
fi
 
# CP IP resolved at runtime - no hardcoding
# cp_ip="$(docker inspect -f "{{ (index .NetworkSettings.Networks \"$KIND_NET\").IPAddress }}" \
#   "$CLUSTER_NAME-control-plane")"

ok "control plane $CLUSTER_NAME-control-plane @ $CP_IP"