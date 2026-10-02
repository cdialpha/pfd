# Usage: make help | make up | make -j up | make reset CLUSTER_NAME=foo 

SHELL := bash 
.SHELLFLAGS := -eou pipefail -c
.DELETE_ON_ERROR:
.DEFAULT_GOAL := help

# make min version for features
# are mise & shellcheck required by the makefile? 
need := 4.3
ifneq ($(need),$(firstword $(sort $(MAKE_VERSION) $(need))))
$(error GNU Make >= $(need) required, found $(MAKE_VERSION))
endif

# directory vars 
ROOT        := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
DEPLOY_DIR  := $(ROOT)
S           := $(DEPLOY_DIR)/scripts
TLS         := $(DEPLOY_DIR)/tls
COMPOSE     := $(DEPLOY_DIR)/db/docker-compose.yaml
ROOT_APP    := $(DEPLOY_DIR)/bootstrap/root-app.yaml

# Load environment variables from .env or .env.example if present
ENV_FILE := $(firstword $(wildcard $(ROOT)/.env $(ROOT)/.env.example))
ifneq ($(ENV_FILE),)
include $(ENV_FILE)
export $(shell sed -n 's/^\([A-Za-z_][A-Za-z0-9_]*\)=.*/\1/p' $(ENV_FILE))
endif
export PROJECT_ROOT := $(ROOT)
# tells lib.sh load_env() to skip re-sourcing (keeps cmd-line overrides)
export ENV_LOADED   := 1

# file lists
CA_CERTS  := $(TLS)/ca/ca.crt $(TLS)/ca/ca.key
SRV_CERTS := $(TLS)/server/tls.crt $(TLS)/server/tls.key
CERTS     := $(CA_CERTS) $(SRV_CERTS)

.PHONY: help up down reset status preflight network certs db cluster \
        secrets cni argocd bootstrap clean-certs lint
 
help: ## list targets
	@grep -hE '^[a-zA-Z_-]+:.*## ' $(firstword $(MAKEFILE_LIST)) \
	  | awk 'BEGIN{FS=":.*## "}{printf "  %-12s %s\n", $$1, $$2}'
 
up: bootstrap ## full init (try: make -j up) 
	@echo "✓ up - cluster '$(CLUSTER_NAME)' ready"

preflight: ## tools, versions, env vars, config files (R-only)
	$(S)/preflight.sh

network: preflight ## docker bridge net w/ pinned subnet
	$(S)/network.sh
 
# Real file targets. &: = grouped target (1 recipe run makes all files).
# | preflight = order-only (phony prereq must not force regen).
$(CA_CERTS) &: $(S)/ca.sh | preflight
	$(S)/ca.sh
 
$(SRV_CERTS) &: $(S)/server_certs.sh $(CA_CERTS)
	$(S)/server_certs.sh
 
CERTS := $(CA_CERTS) $(SRV_CERTS)
certs: $(CERTS) ## CA + server cert (skipped if up to date)
 
# compose file should join the kind net, e.g.
#   networks: { default: { name: $${KIND_NET}, external: true } }

db: network certs ## postgres etc. via compose
	docker compose -f $(COMPOSE) up -d --wait

cluster: network ## kind cluster (no CNI yet)
	$(S)/cluster.sh
 
secrets: cluster certs ## ns + CA secret for cert-manager
	$(S)/secrets.sh

cni: cluster ## cilium (KPR, L2 announcements)
	$(S)/cilium.sh
 
argocd: cni secrets ## argo cd via helm
	$(S)/argocd.sh
 
bootstrap: argocd db ## apply app-of-apps root
	kubectl --context kind-$(CLUSTER_NAME) apply -f $(ROOT_APP)

# system lifecycle 
down: ## delete cluster + db (PURGE=1 also removes net & db volumes)
	$(S)/down.sh
 
reset: ## down, then up
	$(MAKE) --no-print-directory down
	$(MAKE) --no-print-directory up
 
status: ## summary of every layer
	$(S)/status.sh
 
clean-certs: ## remove generated certs (next up regenerates)
	rm -f $(CERTS)
 
lint: ## shellcheck all scripts
	shellcheck -x $(S)/*.sh $(S)/tls/*.sh

