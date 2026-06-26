#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh" 

load_env 
check_files 
require kind kubectl helm cilium
# TO DO: Require specific version minimums? 

# Kind Cluster


if ! kind create cluster --quiet --name "$CLUSTER_NAME" --config cluster-config.yaml; then
    echo "✗ cluster init failed" >&2
    exit 1
  fi

CP_IP=$(kubectl get node -l node-role.kubernetes.io/control-plane='' \
       -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

# TO DO: figure out how to avoid CP_IP hardcoding. 

helm repo add cilium https://helm.cilium.io/
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm install cilium cilium/cilium \
      --namespace kube-system \
      --set kubeProxyReplacement=true \
      --set k8sServiceHost=${CP_IP}\
      --set k8sServicePort=6443 \
      --set l2announcements.enabled=true

# kubectl wait --for=condition=Ready node --all --timeout=120s
cilium status --wait   # or kubectl wait

helm upgrade --install argocd argo/argo-cd --namespace argocd --create-namespace
kubectl apply -f bootstrap/root-app.yaml

# TO DO init Network Infra 

# Add API GW 


# TO DO Helm Install Accounts Chart from 
    # charts/accoutns? Or chart repo? 



# App manifests / Helm
# helm upgrade --install myapp ./charts/myapp

