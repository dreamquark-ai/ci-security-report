# set default shell
SHELL := /bin/bash
.SHELLFLAGS = -c

NAMESPACE=dreamqaurk-ai
VCS_PROVIDER=github
ORG_NAME=dreamquark-ai
ORB_NAME=security-report
ORB_FILE=./orbs/orb.yml
ORB_DIR=./orbs
VERSION=dev:0.0.5

create-namespace:
	circleci namespace create $(NAMESPACE) $(VCS_PROVIDER) $(ORG_NAME)
.PHONY: create-namespace

create-orb:
	circleci orb create $(NAMESPACE)/$(ORB_NAME)
.PHONY: create-orb

pack-orb:
	circleci orb pack $(ORB_DIR) > $(ORB_FILE)
.PHONY: pack-orb

validate-orb:
	circleci orb validate $(ORB_FILE)
.PHONY: validate-orb

publish-orb:
	circleci orb publish $(ORB_FILE) $(NAMESPACE)/$(ORB_NAME)@$(VERSION)
.PHONY: publish-orb

all: pack-orb validate-orb publish-orb clear
.PHONY: all

clear:
	rm $(ORB_FILE)
.PHONY: clear