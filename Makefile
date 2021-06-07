# set default shell
SHELL := /bin/bash
.SHELLFLAGS = -c

NAMESPACE=dreamquark-ai
VCS_PROVIDER=github
ORG_NAME=dreamquark-ai
ORB_NAME=ci-security-report
ORB_FILE=./orbs/orb.yml
ORB_DIR=./orbs
VERSION=1.0.0

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
	rm -f $(ORB_FILE)
.PHONY: clear