#!/bin/bash

#================
# Script which should always run first when installing WordPress, used to start scripts that download
# and install the various things that are required on this server.
#===============

if [ "$USER" != "root" ]
then
	echo "This script needs to run by using sudo, please try again!"
	exit 2
fi

SCRIPT_PATH=$PWD/WordPress

# Install WordPress
echo "Installing Wordpress and all the requirements for it"
"$SCRIPT_PATH"/InstallWordPress.sh

# Configure MySQL and some stuff for Wordpress files
echo "Configuring MySQL for WordPress!"
"$SCRIPT_PATH"/ConfigureDatabase.sh

# Configures WordPress as much as possible and installs the OpenLDAP plugin
echo "Configuring Wordpress and installing OpenLDAP plugin!"
"$SCRIPT_PATH"/ConfigureWordPress.sh

# Configure Crontab to start making backups of the Mysql database
echo "Configuring Crontab for making MySQL backups!"
"$SCRIPT_PATH"/ConfigureCronWordPress.sh