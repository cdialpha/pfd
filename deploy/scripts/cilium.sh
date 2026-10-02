#!/usr/bin/env bash
set -euo pipefail 
# shellcheck source=lib.sh
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
load_env

CILIUM_CHART_VERSION=${CILIUM_CHART_VERSION:-"1.20.0"}

hc upgrade --install cilium cilium \
  --repo https://helm.cilium.io --version "$CILIUM_CHART_VERSION" \
  --namespace kube-system \
  --set kubeProxyReplacement=true \
  --set k8sServiceHost=auto \
  --set k8sServicePort=6443 \
  --set l2announcements.enabled=true \
  --set operator.replicas=1

# TO DO: vendor cilium crds?

cilium status --context "kind-$CLUSTER_NAME" --wait --wait-duration 5m >/dev/null
ok "cillium $CILIUM_CHART_VERSION healthy"