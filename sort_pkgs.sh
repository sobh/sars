#!/bin/sh
#
# Description:	Sort the package list in 'pkg.tsv' by:
#               1. essential    (reverse)
#               2. server       (reverse)
#               2. ui
#               3. category
#               4. short
#               5. name
#

# If user passed argument, treat it as input file name, else use /dev/stdin
{
	# Read, and output the header as is.
	read header
	echo "$header"
	# Sort the packages
	sort -t"$(printf '\t')" -k10r,10 -k13r,13 -k9,9 -k3,3 -k4,4 -k1,1 # < /dev/stdin
} < "${1:-/dev/stdin}"

