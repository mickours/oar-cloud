#!/bin/bash

#################################
#  OAR setup script for Ubuntu  #
#################################

# exit if error
#set -e

# check rights
if [ "$(whoami)" != "root" ]; then
    echo "ERROR: You must be root to run this script. Try:
sudo $0 $1"
    exit 1
fi

#display prefix
BEGIN_RED='\e[01;31m'
BEGIN_GREEN='\e[0;32m'
END_COLOR='\e[0m'
SCRIPT_START="[${BEGIN_GREEN}START${END_COLOR}]"
SCRIPT_OK="[${BEGIN_GREEN}OK${END_COLOR}]"
SCRIPT_FAIL="[${BEGIN_RED}FAIL${END_COLOR}]"
VM_LIST_FILE_TO_CREATE=
VM_LIST_TO_CREATE=

### USAGE ###
usage(){
    echo "USAGE:
    $0 [-hicr]
    -h
        display this Help
    -i 
        Install and configure lxc 
    -c 
        Create VMS
    -r
        start Runtime

    default (without argument) run the 3 steps: Install, Configure
    ";
    exit 1
}

### INSTALL ###
lxc_install(){
    
	echo -e "$SCRIPT_START Starting LXC installation..."

	#Install lxc
	apt-get install lxc bridge-utils debootstrap

	#Mounting cgroups for this session
	cgroup /sys/fs/cgroup cgroup defaults 0 0
	
	#Enabling previous modifications
	mount -a
	
	# Checking lxc configuration
	lxc-checkconfig
	if [ $? -ne 0 ]; then
        echo "$SCRIPT_FAIL Check validation for LXC failed, aborting."
        return 1
	fi;
	
    echo -e "$SCRIPT_OK LXC install finished."
    return 0
}


### CONFIGURE ###
lxc_create_vms(){
	echo -e "$SCRIPT_START LXC VMs creation starting..."
	compteur=0

	echo -e "$SCRIPT_START LXC reading VM to create from file..."
# a modifier : chaque ligne du fichier contiendra : nomVM OS
	for vm in $(cat $VM_LIST_FILE_TO_CREATE); do 
		echo "$vm"
		if [ $compteur -eq 0 ]; then
			VM_LIST_TO_CREATE=$vm
		else
			VM_LIST_TO_CREATE="$VM_LIST_TO_CREATE $vm"
		fi;
		compteur=$(expr $compteur + 1)
	done
	echo "la liste des VMs est : $VM_LIST_TO_CREATE"

	
	echo -e "$SCRIPT_START creating VMs and OS installation"

	for vm in $VM_LIST_TO_CREATE; do
	lxc-create -t ubuntu -n $vm
    	echo -e "$SCRIPT_OK $vm created successfully."
	done
    	return 0

	echo -e "$SCRIPT_OK $vm All VMs have been created successfully."
}


if [ $# -eq 0 ]; then
    lxc_install
    lxc_create_vms
fi;

while getopts ":ic:rh" opt; do
  case $opt in
    i)
      lxc_install
      ;;
    c)
      VM_LIST_FILE_TO_CREATE=$OPTARG
      lxc_create_vms
      ;;
    h)
      usage
      ;;
    r)
      #runtim
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
  esac
done

echo -e "$SCRIPT_OK LXC setup finished."
exit 0
