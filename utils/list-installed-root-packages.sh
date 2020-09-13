#!/bin/sh

# This script will list all packages, which are marked for manual
# installation and don't have any reverse-dependencies (i.e., no
# other package require them). These packages are also called roots
# of the dependency tree.

deps=$(mktemp /tmp/package-deps.XXXX.txt)
trap "rm -f $deps" EXIT INT TERM

# Collect list of all package requirements
awk '/^Status: / { ok=!!($2 == "install" || $4 == "config-files") };
     ok && /^(Depends|Recommends): / {print $0};
	' /var/lib/dpkg/status \
	| grep -E '^(Depends|Recommends): ' | cut -d' ' -f2- \
	| sed -e 's/, /\n/g' -e 's/ | /\n/g' | cut -d' ' -f1 \
	| sort -u \
	> "$deps"

# List only packages, which don't appear as a dependency
apt-mark showmanual | sort -u | comm -23 /dev/stdin "$deps"
