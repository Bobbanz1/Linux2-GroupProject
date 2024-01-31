#!/bin/bash

if [ "$USER" != "root" ]
then
	echo "This script needs to run by using sudo, please try again!"
	exit 2
fi

# Grab the path to our current location, used so we get the absolute path for the crontab scripts
echo "0 0   * * *   root    $PWD/OpenLDAP/BackupWP.sh" >> /etc/crontab

systemctl restart cron.service