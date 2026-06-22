#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh" 

load_env 
check_files 
require kind kubectl helm

# Kind Cluster
kind create cluster --name "$CLUSTER_NAME" --config cluster-config.yaml

# Wait for CTRL-P
kubectl wait --for=condition=Ready node --all --timeout=120s

# Bootstrap

# ArgoCD Init 

# kubectl create namespace argocd || true
# kubectl apply -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
# kubectl apply -f bootstrap/root-app.yaml

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update
helm upgrade --install argocd argo/argo-cd --namespace argocd --create-namespace
kubectl apply -f bootstrap/root-app.yaml

# TO DO init Network Infra 
    # TO DO add CNI 
    # Add API GW 


# TO DO Helm Install Accounts Chart from 
    # charts/accoutns? Or chart repo? 



# App manifests / Helm
# helm upgrade --install myapp ./charts/myapp

