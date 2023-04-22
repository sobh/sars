#!/usr/bin/awk -f
# Author:	Mohamed Sobh
#
# Description:	List packages in the 'pkg.tsv' file as per the input parameters.
#
# Parameters:
#	os	Operating System (openbsd, arch, void)
#	machine	Machine type (desktop, laptop, server)
#

# Set the 'Field Seperator', and assert the definition of the mandatory
# parameters.
BEGIN {
	FS="\t";
	if(!os){
		print "Error: No 'os' variable defined.";
		exit 1;
	}
	if(!machine){
		print "Error: No 'machine' variable must be defined as desktop, laptop, or server.";
		exit 1;
	}
}

# Load the data header into an associative array
NR==1 {
	for(i=1; i<=NF; i++){
		idx[$i] = i
	}
}

NR > 1 {
	#---- Skip package if ----#
	# Not applicable to OS
	if(!$idx[os]){ next }

	# Not applicable to the machine type
	if($idx[machine]!="TRUE") { next }

	# The package is not essential, and the user did not request listing the
	# non essential packages by defining the 'extra' variable.
	if($idx["essential"]!="TRUE" && !extra ) { next }


	print $idx[os]
}
