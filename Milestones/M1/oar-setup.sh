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


### SETTINGS ####
OAR_VERSION=2.5
DEBIAN_VERSION=sid

#user definition (to modify if necessary)
#$USER=my_hostname
HOME=/home/$USER/
USER_GROUP=$USER

#get local path
SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )
#hosts address map file path
HOSTS_ADDR=${SCRIPTPATH}/hosts
#hosts names list file path
HOSTS_NAME=${SCRIPTPATH}/hosts-names
#oar configuration file path
OAR_CONFIG=${SCRIPTPATH}/oar.conf

#sql config for database creation (to modify if necessary)
ADMIN_USER=root
ADMIN_PASS=oar

#display prefix
BEGIN_RED='\e[01;31m'
BEGIN_GREEN='\e[0;32m'
END_COLOR='\e[0m'
SCRIPT_START="[${BEGIN_GREEN}START${END_COLOR}]"
SCRIPT_OK="[ ${BEGIN_GREEN}OK${END_COLOR}  ]"
SCRIPT_FAIL="[${BEGIN_RED}FAIL${END_COLOR} ]"

### USAGE ###
usage(){
    echo "USAGE:
    $0 [-hicr]
    -h
        display this Help
    -i 
        Install oar
    -c 
        Configure oar
    -r
        start Runtime for oar

    default (without argument) run the 3 steps: Install, Configure and Runtime.

    Problems or questions?
    contact Michael Mercier <michael.mercier@e.ujf-grenoble.fr>
    ";
    exit 1
}

### IF FAILED ###
# give a description of the action. If it failed: show the message and exit 
# if_failed(){
#     if [ $? -ne 0 ]; then
#         echo "$SCRIPT_FAIL Failed to $1, aborting."
#         return 1
#     fi
# }


### INSTALL ###
oar_install(){
    trap 'echo -e "$SCRIPT_FAIL Failed to install, aborting."; exit 1;' ERR
	echo -e "$SCRIPT_START OAR install..."

	#Install mysql
	apt-get install mysql-server

    # Add the OAR repository (choose the right one. See http://oar.imag.fr/repositories/)
    echo "deb http://oar-ftp.imag.fr/oar/$OAR_VERSION/debian $DEBIAN_VERSION main" > /etc/apt/sources.list.d/oar.list
    command -v foo >/dev/null 2>&1 || { apt-get install curl; }
    curl http://oar-ftp.imag.fr/oar/oarmaster.asc | sudo apt-key add -
    apt-get update 

	#Install OAR server for the MySQL backend
	apt-get install oar-server oar-server-mysql
    if [ $? -ne 0 ]; then
        echo "$SCRIPT_FAIL Failed to install oar-server, aborting."
        return 1
    fi

	#Install OAR frontend for the MySQL backend
	apt-get install oar-user oar-user-mysql
    if [ $? -ne 0 ]; then
        echo "$SCRIPT_FAIL Failed to install oar-frontend, aborting."
        return 1
    fi

	#install OAR node
	apt-get install oar-node
    if [ $? -ne 0 ]; then
        echo "$SCRIPT_FAIL Failed to install oar-node, aborting."
        return 1
    fi

    echo -e "$SCRIPT_OK OAR install finished."
    return 0
}


### CONFIGURE ###
oar_configure(){
    trap 'echo -e "$SCRIPT_FAIL Failed to configure OAR, aborting."; exit 1;' ERR
    echo -e "$SCRIPT_START OAR configuration..."

    #change oar.conf
    cp OAR_CONFIG /etc/oar/oar.conf
    chown oar:root /etc/oar/oar.conf
    chmod 644 /etc/oar/oar.conf

    #create database
    service mysql start
    oar-database --create --db-admin-user $ADMIN_USER --db-admin-pass $ADMIN_PASS

    #populate /etc/hosts
    echo $HOSTS_ADDR >> /etc/hosts

    #add hosts node
    ##create node settings
    oar_resources_init $HOSTS_NAME

    ##run node settings
    sh /tmp/oar_resources_init.txt

    #get ssh conf
    cp -R /var/lib/oar/.ssh $HOME
    chown -R $USER:$USER_GROUP $HOME.ssh

    echo -e "$SCRIPT_OK OAR configuration finished."
    return 0
}


### RUNTIME ###
oar_runtime(){
    #trap 'echo -e "$SCRIPT_FAIL Failed to launch runtime, aborting."; exit 1;' ERR
    echo -e "$SCRIPT_START OAR setup runtime..."
    #check config
    #TODO

    #handle services
    ##stop cgroup-lite (necessary only of OAR cgroups are used)
    #service cgroup-lite stop

    ##mysql
    service mysql start

    ##sshd
    service ssh start

    ##oar-server
    service oar-server start

    ##oar-node
    service oar-node start

    #activate nodes
    for host in $(cat $HOSTS_NAME)
    do
        oarnodesetting -s Alive -h $host
    done

    echo -e "$SCRIPT_OK OAR setup runtime finished."
    return 0
}

### MAIN ###
echo -e "$SCRIPT_START OAR setup..."
if [ $# -eq 0 ]; then
    oar_install
    oar_configure
    oar_runtime
fi;
 
while getopts ":icrh" opt; do
  case $opt in
    i)
      oar_install
      ;;
    c)
      oar_configure
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

echo -e "$SCRIPT_OK OAR setup finished."
exit 0
