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
        Install Open vSwitch and create a switch (bridge)
    -c 
        Configure a new vlan for new VMs

    default (without argument) run the 3 steps: Install and Configure.
    ";
    exit 1
}

### INSTALL ###
openvswitch_install(){
    
	echo -e "$SCRIPT_START Starting Openvswitch installation..."

	#Install openvswitch
	apt-get install openvswitch-switch openvswitch-datapath-source

	#Datapath building for openvswitch-datapath-source, as will be preinstalled later in kernel 3.3
	#apt-get install -t testing linux-headers-$(uname -r)
	#apt-get install -t testing module-assistant
	
	#Building openvswitch-datapath
	m-a build -f openvswitch-datapath
	dpkg -i /usr/src/openvswitch-datapath-module-$(uname -r)_*.deb

	#Removing linux bridge due to Open vSwitch conflits
	rmmod bridge
	#Blacklists the linux bridge since we want to use OpenVswitch instead
	echo "blacklist bridge" >> /etc/modprobe.d/bridge-blacklist.conf
    	
	echo -e "$SCRIPT_OK Open vSwitch installed successfully."
	return 0
}


### START OPENVSWITCH AND CREATE THE SWITCH ###
openvswitch_start(){
	echo -e "$SCRIPT_START Stating Open vSwitch and creating the switch..."

	#Creating the virtual switch
	#ovs-vsctl add-br vswitch
	
	#Add vlan1 port on vswitch bridge, next step should be creating a vlan with a number that does no exists
	#ovs-vsctl add-br vlan1 vswitch 1

	# FAIL TO START A VM with lxc-start -n vm1

	echo -e "$SCRIPT_OK $vm The switch have been created successfully."
	return 0
}


### MAIN ###
echo -e "$SCRIPT_START Starting Open vSwitch script..."
if [ $# -eq 0 ]; then
    openvswitch_install
    openvswitch_start
    oar_runtime
fi;
 
while getopts ":ic:rh" opt; do
  case $opt in
    i)
      openvswitch_install
      ;;
    c)
      VM_LIST_FILE_TO_CREATE=$OPTARG
      openvswitch_start
      ;;
    r)
      oar_runtime
      ;;
    h)
      usage
      ;;
    \?)
      echo "Invalid option: -$OPTARG" >&2
      usage
      ;;
  esac
done

echo -e "$SCRIPT_OK Open vSwitch setup finished."
exit 0
