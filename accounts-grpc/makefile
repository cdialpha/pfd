# Config variables 
REGISTRY := ghcr.io
GH_USER := cdialpha
GHCR_TOKEN := $(shell echo $$GH_TOKEN)
IMAGE_NAME := accounts
VERSION := v1.0

IMAGE_PATH := $(REGISTRY)/$(shell echo $(GH_USER) | tr '[:upper:]' '[:lower:]')/$(IMAGE_NAME):$(VERSION)

.PHONY: all setup build tag push clean

all: setup build tag push clean

# AuthN to GHCR 
setup:
	@echo "checking env vars: $(REGISTRY), $(GH_USER), $(GHCR_TOKEN)"
	@if [ -z "$(GH_USER)" ] || [ -z "$(GHCR_TOKEN)" ]; then \
		echo "Error: GH_USER & GH_TOKEN env vars must be set"; \
		exit 1; \
	fi

# login:
# 	@echo "Logging in to $(REGISTRY) as $(GH_USER)"
# 	@echo "$(GHCR_TOKEN)" | docker login $(REGISTRY) -u "$(GH_USER)" --password-stdin

#Build the Docker image
build:
	docker buildx build -t $(IMAGE_PATH) -f ./dockerfile .

# Tag recipe not needed as build uses FQ tag)

push: 
	docker push $(IMAGE_PATH)

clean:
	docker rmi $(IMAGE_PATH) || true

