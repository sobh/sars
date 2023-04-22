#!/bin/sh
#
# Description: Test the SARS configuration. (Sobh Awsome Rice System)
#

#---- Includes -----------------------------------------------------------------
include ()
{
	file="$1"
	[ -f "$file" ] && { . "$file"; return 0; } ||
		printf "\e[91mError\e[0m : Unable to find '$file'."
}
include "$HOME/scripts/sh/log.sh"
#---- Parameters ---------------------------------------------------------------
cmd_list=$(cat << __EOF
ssh
git
__EOF
)

#---- Main ---------------------------------------------------------------------
for cmd in $cmd_list ; do
	command -v $cmd 2>&1 >/dev/null &&
		success "Found command $cmd" ||
		failure "Unable to find command $cmd"
done
