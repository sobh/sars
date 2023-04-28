#!/bin/sh
#
# Description:	Sort the package list in 'pkg.tsv' by category, short, name.
#

# If user passed argument, treat it as input file name, else use /dev/stdin
{
	# Read, and output the header as is.
	read header
	echo "$header"
	# Sort the packages
	sort -t"$(printf '\t')" -k3,3 -k4,4 -k1,1 < /dev/stdin
} < "${1:-/dev/stdin}"

