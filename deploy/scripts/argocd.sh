#!/usr/bin/env bash
# argocd.sh - install/upgrade Argo CD & wait until CRDs + server are ready
set -euo pipefail
# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
load_env

ARGOCD_CHART_VERSION=${ARGOCD_CHART_VERSION:-"10.9.0"}

hc upgrade --install argocd argo-cd \
  --repo https://argoproj.github.io/argo-helm --version "$ARGOCD_CHART_VERSION" \
  --namespace argocd --create-namespace \
  --wait --timeout 5m

kc wait --for=condition=Established crd/applications.argoproj.io --timeout=60s >/dev/null
kc -n argocd rollout status deploy/argocd-server --timeout=300s >/dev/null
ok "argocd ready - admin pw: kubectl --context kind-$CLUSTER_NAME -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d"