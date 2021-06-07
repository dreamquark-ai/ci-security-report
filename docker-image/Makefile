# set default shell
SHELL := /bin/bash
.SHELLFLAGS = -c

DOCKER_IMAGE=quay.io/dreamquark/security-report
DOCKER_TAG=latest
DOCKERFILE=./Dockerfile

BUILD_DIR = .

.SILENT: ;			   # no need for @
.ONESHELL: ;			 # recipes execute in same shell
.NOTPARALLEL: ;		  # wait for this target to finish
.EXPORT_ALL_VARIABLES: ; # send all vars to shell
default: help;   # default target

help: ## display commands help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help

_build-docker:
	echo "Building $(DOCKER_IMAGE):$(DOCKER_TAG) ($(DOCKERFILE))..."
	echo "Using extra args : $(EXTRA_ARGS)"
	docker build -q --rm -t $(DOCKER_IMAGE):$(DOCKER_TAG) -f $(DOCKERFILE) $(BUILD_DIR) $(EXTRA_ARGS)
	echo "Done building $(DOCKER_IMAGE):$(DOCKER_TAG) ($(DOCKERFILE))."
.PHONY: _build-docker

_push-docker:
	echo "Pushing $(DOCKER_IMAGE):$(DOCKER_TAG)..."
	docker push $(DOCKER_IMAGE):$(DOCKER_TAG)
	echo "Done pushing $(DOCKER_IMAGE):$(DOCKER_TAG)"
.PHONY: _push-docker

build-security-report: ## build security-report
	# https://unix.stackexchange.com/questions/129084/in-bash-how-can-i-echo-the-variable-name-not-the-variable-value
	$(MAKE) _build-docker\
		DOCKERFILE=$(DOCKERFILE)\
		DOCKER_TAG=$(DOCKER_TAG)
.PHONY: build-security-report

deploy-security-report: ## build security-report
	# https://unix.stackexchange.com/questions/129084/in-bash-how-can-i-echo-the-variable-name-not-the-variable-value
	$(MAKE) build-security-report \
		DOCKERFILE=$(DOCKERFILE)\
		DOCKER_TAG=$(DOCKER_TAG)
	$(MAKE) _push-docker\
		DOCKER_TAG=$(DOCKER_TAG)
.PHONY: deploy-security-report