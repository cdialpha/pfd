# Configuration variables 
REGISTRY := ghcr.io
IMAGE_NAME := account-server
VERSION := v1.0

# Compute full image path (converts username to lowercase, OCI)
IMAGE_PATH := $(REGISTRY)/$(shell echo $(GH_USER) | tr '[:upper:]' '[:lower:]')/$(IMAGE_NAME):$(VERSION)

.PHONY: all login build tag push clean

# default target 
all: setup login build tag push clean

# AuthN to GHCR 
setup:
	@echo "checking env vars: $(REGISTRY), $(GH_USER), $(GH_TOKEN)"
	@if [ -z "$(GH_USER)" ] || [ -z "$(GH_TOKEN)" ]; then \
		echo "Error: GH_USER & GH_TOKEN env vars must be set"; \
		exit 1; \
	fi

login:
	@echo "Logging in to $(REGISTRY) as $(GH_USER)"
	@echo "$(GH_TOKEN)" | docker login $(REGISTRY) -u "$(GH_USER)" --password-stdin

#Build the Docker image
build:
	docker build -t $(IMAGE_PATH) -f dockerfile ./accounts/

# Tag recipe not needed as build uses FQ tag)

push: 
	docker push $(IMAGE_PATH)

clean:
	docker rmi $(IMAGE_PATH) || true

