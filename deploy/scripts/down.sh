#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/lib.sh" 

load_env 
check_files 
require kind kubectl helm
require_cluster

kind delete cluster --name "$CLUSTER_NAME"

# 4. Clean up dangling Docker resources kind may leave
#docker network inspect kind >/dev/null 2>&1 && \
#  docker network rm kind 2>/dev/null || true

# 5. (optional) prune leftover volumes/images
# docker volume prune -f
# docker image prune -f

