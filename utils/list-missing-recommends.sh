#!/bin/sh

dpkg-query -W -f='${Package}	(${Status}):	${Recommends}\n' \
	| grep -F '(install ok installed)' \
	| cut -d'	' -f3- \
	| sed -e 's/, /\n/g' -e 's/ | /\n/g' | cut -d' ' -f1 \
	| sort | uniq -c | sort -n \
	| while read num p
do
	[ "$p" ] || continue
	{ dpkg -l "$p" | grep -qs '^ii'; } && continue
	aptitude search "~P$p ~i" >/dev/null && continue
	printf "%8d %s\n" $num $p
done
