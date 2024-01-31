#!/bin/bash

#=========================#
# Script which should be the only one that is ran by the user.
# Allows the User to select whether they want to install WordPress or OpenLDAP
#
# Todo:
# * [#] Allow User to select between installing WordPress or OpenLDAP
#=========================#

if [ "$USER" != "root" ]
then
	echo "This script needs to run by using sudo, please try again!"
	exit 2
fi

echo "Hello World!
Current time is: $(date '+%H:%M:%S')"

VALID_INPUT=true
while [ $VALID_INPUT == true ]; do
	# Gives the user options to choose from and then takes the inputted word or number and assigns it to a variable.
	read -rp "#=======================================================#
# Please select what you wish to install on this server:
# 1) WordPress
# 2) OpenLDAP
# 3) Quit
#=======================================================#
" SELECTED_PROGRAM
	INSENSITIVE_PROGRAM=$(tr '[:upper:]' '[:lower:]' <<<"$SELECTED_PROGRAM")
	# Goes through the possible options that the person might have inputted and executes the code associated with that entry.
	case $INSENSITIVE_PROGRAM in
		"1" | "wordpress" | "WordPress")
			read -rp "Case Sensitive! Are you sure you wish to install WordPress on this Machine: Yes/No: " CONFIRMATION
			if [ "$CONFIRMATION" == "Yes" ];
			then
				echo "Installing WordPress"
				chmod +x ./*.sh ./WordPress/*.sh ./Crontab/CrontabUpdate.sh
				VALID_INPUT=false
				./Initial_Crontab_Config.sh
				./WordPress/StartInstallationWordPress.sh
			fi
			;;
		"2" | "openldap" | "OpenLDAP")
			read -rp "Case Sensitive! Are you sure you wish to install WordPress on this Machine: Yes/No: " CONFIRMATION
			if [ "$CONFIRMATION" == "Yes" ];
			then
				echo "Installing OpenLDAP"
				chmod +x ./*.sh OpenLDAP/*.sh Crontab/CrontabUpdate.sh
				VALID_INPUT=false
				./Initial_Crontab_Config.sh
				./OpenLDAP/StartInstallationLDAP.sh
			fi
			;;
		"3" | "quit" | "Quit")
			echo "Terminating the script!"
			VALID_INPUT=false
			;;
		*)
			echo "Not a valid entry. Try again!"
			;;
	esac
done