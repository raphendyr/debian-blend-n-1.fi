#!/bin/sh
r="/sys/kernel/iommu_groups"

ls "$r" | sort -n | while read g; do
	echo "IOMMU Group $g:"
	ls "$r/$g/devices" | sort | while read d; do
		lspci -nns "$d" | sed 's/^/	/'
	done
done
