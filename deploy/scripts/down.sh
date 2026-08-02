#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh" 

load_env 
check_files 
require kind kubectl helm
require_cluster

kind delete cluster --name "$CLUSTER_NAME"

# 4. Clean up dangling Docker resources kind may leave
docker network inspect kind
docker network rm kind 

# 5. (optional) prune leftover volumes/images
# docker volume prune -f
# docker image prune -f

