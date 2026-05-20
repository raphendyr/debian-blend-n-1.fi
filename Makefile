#!/usr/bin/make -f
include /usr/share/blends-dev/Makefile

TARGET_DIST := "testing"
TARGET_ARCH := $(shell dpkg-architecture -q DEB_TARGET_ARCH)

CHANGES := ../$(BLEND)_$(VERSION)_$(TARGET_ARCH).changes
REPO_DIR := /opt/local-blend-n-1.fi
SOURCE_LIST_FILE := /etc/apt/sources.list.d/local-blend-n-1.fi.list


clean-releases: debian/control
	rm -vf ../$(BLEND)_*.dsc \
		../$(BLEND)_*.git \
		../$(BLEND)_*.tar.* \
		../$(BLEND)_*_*.build \
		../$(BLEND)_*_*.buildinfo \
		../$(BLEND)_*_*.changes
	for pkg in $(shell dh_listpackages); do rm -vf ../$${pkg}_*_*.deb; done

$(CHANGES): $(BLEND)-tasks.desc debian/control
	debuild

build-release: $(CHANGES)

build-dev: $(BLEND)-tasks.desc debian/control
	@if [ "$$(git diff --name-only --cached)" ]; then \
		echo "ERROR: You have staged files (git), thus it's not possible to do dev builds, as that requires a temporary git commit"; exit 1; fi
	dch -t -l~test "dev test build: $(shell date)"
	if git log -1 --oneline | grep -qs "WIP: dev build$$"; then \
		git commit -a -m "WIP: dev build" --amend; else \
		git commit -a -m "WIP: dev build"; fi
	debuild -uc -us
	if git log -1 --oneline | grep -qs "WIP: dev build$$"; then \
		git reset HEAD^; fi

upload: $(CHANGES)
	@echo Uploading changes to the remote, see ~/.dupload.conf
	for changes in ../$(BLEND)_$(VERSION)_*.changes; do \
		dupload -t deb.n-1.fi $$changes ; \
	done

debian-local.override: debian/control
	@echo "# pkg priority section" > debian-local.override
	@grep "^Package:" debian/control | awk '{print $$2 " optional misc"}' >> debian-local.override

deploy-local: $(BLEND)-tasks.desc debian/control debian-local.override
	debuild -us -uc
	@# Setup
	@echo "Ensure local repo is hooked, creating $(REPO_DIR)..."
	sudo mkdir -p $(REPO_DIR)
	@if [ ! -f $(SOURCE_LIST_FILE) ]; then \
		echo "deb [trusted=yes] file:$(REPO_DIR) ./" | sudo tee $(SOURCE_LIST_FILE); \
	fi
	@# Sync
	@echo "Copying newly built .deb packages (version $(VERSION)) to $(REPO_DIR)..."
	sudo rm -f $(REPO_DIR)/*.deb
	sudo cp -v ../*_$(VERSION)_*.deb $(REPO_DIR)/
	@# Update repo
	@echo "Generating local repository package index..."
	cd $(REPO_DIR) && dpkg-scanpackages . $(CURDIR)/debian-local.override | gzip -9c | sudo tee Packages.gz > /dev/null
	@# Update apt
	@echo "Refreshing system APT package database..."
	sudo apt update
	@echo "Success! Run 'sudo tasksel' or 'sudo tasksel install [task]' to install."


.PHONY: clean-releases build-release build-local upload deploy-local
