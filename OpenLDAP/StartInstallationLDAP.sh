#!/bin/bash

#================
# Script which should always run first when installing OpenLDAP, used to start scripts that download
# and install the various things that are required on this server in order for it to run OpenLDAP.
# This is similar in function to the InstallConfigureWordPress.sh file
#===============

# Needs to be ran as root no matter what
if [ "$USER" != "root" ]; then
	echo "This script needs to run by using sudo, please try again!"
	exit 2
fi

SCRIPT_PATH=$PWD/OpenLDAP

# Install OpenLDAP
echo "Installing OpenLDAP and all the requirements for it"
"$SCRIPT_PATH"/InstallOpenLDAP.sh

# Setup Crontab to handle making backups of the code
echo "Configuring Crontab to enable Automatic Backups of database"
"$SCRIPT_PATH"/ConfigureCronLDAP.sh