#!/bin/sh
#
# Description:	Sort the package list in 'pkg.tsv' by category, short, name.
#

FNAME="$1"

hfile=$(mktemp)
dfile=$(mktemp)

head -n1 $FNAME > $hfile
tail -n+2 $FNAME | sort -t"$(printf '\t')" -k3,3 -k4,4 -k1,1 > $dfile

cat $hfile $dfile
rm -rf $hfile $dfile
