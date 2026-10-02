#!/usr/bin/env bash
# secrets.sh - namespace + CA secret for cert-manager (create-or-update)
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
load_env

TLS_DIR="${PROJECT_ROOT}/deploy/tls"
ns=cert-manager

kc create namespace "$ns" --dry-run=client -o yaml | kc apply -f - >/dev/null
kc -n "$ns" create secret tls cluster-ca \
  --cert="$TLS_DIR/ca/ca.crt" --key="$TLS_DIR/ca/ca.key" \
  --dry-run=client -o yaml | kc apply -f - >/dev/null

ok "secret $ns/cluster-ca applied"

#TO DO: Set up secrets encryption?

# old 
# CP_IP=$(kubectl get node -l node-role.kubernetes.io/control-plane='' \
#  -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')
# TO DO: figure out how to avoid CP_IP hardcoding. 
#TO DO: Make sure generated secrets are git ignored