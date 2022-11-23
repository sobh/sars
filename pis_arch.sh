#!/bin/sh
#
# Post Install Script - Arch Linux
#

# Move /usr/local/bin to /usr/bin, for compatability with OpenBSD
if [ ! -h "/usr/local/bin" ]; then
	echo "Moving '/usr/local/bin' to '/usr/bin'."
	if [ -d "/usr/local/bin" ] ; then
		sudo mv /usr/local/bin/* /usr/bin/
		sudo rmdir /usr/local/bin
	fi
	sudo link -s /usr/bin /usr/local/bin
else
	echo "'/usr/local/bin' is already linked to '$(readlink -f /usr/local/bin)'."
fi
