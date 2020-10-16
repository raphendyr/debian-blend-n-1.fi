#!/usr/bin/make -f
include /usr/share/blends-dev/Makefile

TARGET_DIST := "testing"
TARGET_ARCH := $(shell dpkg-architecture -q DEB_TARGET_ARCH)

CHANGES := ../$(BLEND)_$(VERSION)_$(TARGET_ARCH).changes


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

build-local: $(BLEND)-tasks.desc debian/control
	@if [ "$$(git diff --name-only --cached)" ]; then \
		echo "ERROR: You have staged files (git), thus it's not possible to do local builds, as that requires a temporary git commit"; exit 1; fi
	dch -t -l~test "Local test build: $(shell date)"
	if git log -1 --oneline | grep -qs "WIP: local build$$"; then \
		git commit -a -m "WIP: local build" --amend; else \
		git commit -a -m "WIP: local build"; fi
	debuild -uc -us
	if git log -1 --oneline | grep -qs "WIP: local build$$"; then \
		git reset HEAD^; fi

upload: $(CHANGES)
	@echo Uploading changes to the remote, see ~/.dupload.conf
	for changes in ../$(BLEND)_$(VERSION)_*.changes; do \
		dupload -t deb.n-1.fi $$changes ; \
	done


.PHONY: clean-releases build-release build-local upload
