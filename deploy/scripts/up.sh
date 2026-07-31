#!/usr/bin/env bash


PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

source "$PROJECT_ROOT/scripts/lib.sh" 
load_env 
check_files 
require kind kubectl helm cilium openssl
# TO DO: Require specific version minimums? 

echo "NET=[$KIND_NET] SUBNET=[$KIND_SUBNET] GW=[$KIND_GW]" >&2

# Ensure the docker network exists w/ pinned subnet (idempotent) 
if ! docker network inspect "$KIND_NET" >/dev/null 2>&1; then 
  docker network create -d bridge --subnet "$KIND_SUBNET" --gateway "$KIND_GW" "$KIND_NET" 
else 
  # Verify existing net matches expected subnet; fail loud if not 
  existing=$(docker network inspect "$KIND_NET" -f '{{ (index .IPAM.Config 0).Subnet }}') 
  if [[ "$existing" != "$KIND_SUBNET" ]]; then 
    echo "ERROR: docker network '$KIND_NET' exists w/ subnet $existing, expected $KIND_SUBNET" >&2 
    echo "Run: docker network rm $KIND_NET   (after deleting any kind clusters)" >&2 
    exit 1 
  fi 
fi 

# Generate Certs 
source "$PROJECT_ROOT/tls/setup_ca.sh"
source "$PROJECT_ROOT/tls/generate_server_cert.sh"
# don't need client cert, as cert-manager will generate later.
# source "$PROJECT_ROOT/tls/generate_client_cert.sh" eg

# Init DB
docker compose up -f "$PROJECT_ROOT/deploy/docker-compose.yml" -d


# Kind Cluster
if ! kind create cluster --quiet --name "$CLUSTER_NAME" --config cluster-config.yaml; then
    echo "✗ cluster init failed" >&2
    exit 1
  fi

# CP_IP=$(kubectl get node -l node-role.kubernetes.io/control-plane='' \
#  -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

# TO DO: figure out how to avoid CP_IP hardcoding. 
#TO DO: Make sure generated secrets are git ignored. 

kubectl create secret tls cluster-ca --cert="$PROJECT_ROOT/tls/ca.crt" --key="$PROJECT_ROOT/tls/ca.key" -n cert-manager

#TO DO: Set up secrets encryption? 

helm repo add cilium https://helm.cilium.io/
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
 
helm install cilium cilium/cilium \
      --namespace kube-system \
      --set kubeProxyReplacement=true \
      --set k8sServiceHost=auto \
      --set k8sServicePort=6443 \
      --set l2announcements.enabled=true

# TO DO: vendor cilium crds?

# wait on cilium agent (DS; dataplane) & operator AVAILABLE (>=1), tolerating 1/2 pending quirk:
kubectl -n kube-system rollout status ds/cilium --timeout=300s
kubectl -n kube-system wait deploy/cilium-operator --for=condition=Available --timeout=300s

helm upgrade --install argocd argo/argo-cd --namespace argocd --create-namespace
kubectl apply -f bootstrap/root-app.yaml

# TO DO: init Network Infra w/ IaC tool ? 

