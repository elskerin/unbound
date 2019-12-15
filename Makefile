
REGISTRY := docker.io/klutchell/unbound
AUTHORS := Kyle Harding <https://klutchell.dev>
SOURCE := https://gitlab.com/klutchell/unbound
DESCRIPTION := Unbound is a validating, recursive, caching DNS resolver
TAG := 1.9.6

BUILD_DATE := $(strip $(shell docker run --rm busybox date -u +'%Y-%m-%dT%H:%M:%SZ'))
BUILD_VERSION := $(TAG)
VCS_REF := $(strip $(shell git describe --tags --always --dirty))

DOCKER_CLI_EXPERIMENTAL := enabled
BUILDX_INSTANCE_NAME := $(subst /,-,$(REGISTRY))
BUILD_OPTS := \
	--label "org.opencontainers.image.created=$(BUILD_DATE)" \
	--label "org.opencontainers.image.authors=$(AUTHORS)" \
	--label "org.opencontainers.image.url=$(SOURCE)" \
	--label "org.opencontainers.image.documentation=$(SOURCE)" \
	--label "org.opencontainers.image.source=$(SOURCE)" \
	--label "org.opencontainers.image.version=$(BUILD_VERSION)" \
	--label "org.opencontainers.image.revision=$(VCS_REF)" \
	--label "org.opencontainers.image.title=$(REGISTRY)" \
	--label "org.opencontainers.image.description=$(DESCRIPTION)" \
	--tag $(REGISTRY):$(TAG) \
	--tag $(REGISTRY):latest \
	$(EXTRA_OPTS)

COMPOSE_PROJECT_NAME := $(subst /,-,$(REGISTRY))
COMPOSE_FILE := test/docker-compose.yml
COMPOSE_OPTIONS := -e COMPOSE_PROJECT_NAME -e COMPOSE_FILE -e REGISTRY

.EXPORT_ALL_VARIABLES:

.DEFAULT_GOAL := all

.PHONY: all build buildx test clean binfmt help

all: build test ## build and test a local image

build: ## build and label a local image
	docker build . $(BUILD_OPTS)

buildx: binfmt ## cross-build on supported platforms with buildx
	-docker buildx create --use --driver docker-container --name $(BUILDX_INSTANCE_NAME)
	-docker buildx inspect --bootstrap
	docker buildx build . $(BUILD_OPTS)

test: binfmt ## run a simple image test with docker-compose
	docker-compose up --force-recreate --abort-on-container-exit
	docker-compose down

clean: ## clean dangling images, containers, and build instances
	-docker-compose down
	-docker buildx rm $(BUILDX_INSTANCE_NAME)
	-docker image prune --all --force --filter "label=org.opencontainers.image.title=$(REGISTRY)"

binfmt:
	docker run --rm --privileged aptman/qus -s -- -r
	docker run --rm --privileged aptman/qus -s -- -p

help: ## display available commands
	@grep -E '^[0-9a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
