# !/bin/bash
set -eo pipefail # exit on error, and fail if any command in a pipeline fails

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$PROJECT_ROOT"
# echo "pwd: $(pwd), script dir: $SCRIPT_DIR, project root: $PROJECT_ROOT"

# env vars - load from .env or .env.example if exists, don't fail if missing
if [[ -f .env ]]; then
    echo "Loading env vars from .env file"
    source .env 
elif [[ -f .env.example ]]; then
    echo "No .env file found, loading from .env.example"
    source .env.example
else # fallback to defaults if not set
    echo "No .env or .env.example file found, using defaults"
fi

export CLUSTER_NAME="${CLUSTER_NAME:-dev}"
export K8S_VERSION="${K8S_VERSION:-v1.31.0}"

set -u # enforce unset variables as an error

# check for deps
check_deps() {
    local deps=(kind kubectl helm)
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            echo "Error: $dep is not installed." >&2
            exit 1
        fi
    done
}
check_deps

check_files() {
    local files=(cluster-config.yaml) # add manifests/bootstrap charts/myapp
    for file in "${files[@]}"; do
        if [ ! -e "$file" ]; then
            echo "Error: Required file or directory '$file' is missing." >&2
            exit 1
        fi
    done
}
check_files

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

