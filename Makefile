#!/usr/bin/make -f
include /usr/share/blends-dev/Makefile

TARGET_DIST := "testing"
TARGET_ARCH := $(shell dpkg-architecture -q DEB_TARGET_ARCH)

CHANGES := ../$(BLEND)_$(VERSION)_$(TARGET_ARCH).changes


clean-releases: debian/control
	rm -vf ../$(BLEND)_*.tar.* \
		../$(BLEND)_*.dsc \
		../$(BLEND)_*_*.build \
		../$(BLEND)_*_*.buildinfo \
		../$(BLEND)_*_*.changes
	for pkg in $(shell dh_listpackages); do rm -vf ../$${pkg}_*_*.deb; done

$(CHANGES): $(BLEND)-tasks.desc debian/control
	debuild -i -I

build-release: $(CHANGES)

build-local: $(BLEND)-tasks.desc debian/control
	dch -l~test "Local test build: $(shell date)"
	debuild -i -I -uc -us

upload: $(CHANGES)
	@echo Uploading changes to the remote, see ~/.dupload.conf
	for changes in ../$(BLEND)_$(VERSION)_*.changes; do \
		dupload -t deb.n-1.fi $$changes ; \
	done


.PHONY: clean-releases build-release build-local upload
