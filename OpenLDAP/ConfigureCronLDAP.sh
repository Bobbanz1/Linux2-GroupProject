#!/bin/bash

if [ "$USER" != "root" ]
then
	echo "This script needs to run by using sudo, please try again!"
	exit 2
fi

# Grab the path to our current location, used so we get the absolute path for the crontab scripts
echo "* *   * * 7   root    $PWD/OpenLDAP/BackupLDAP.sh" >> /etc/crontab

systemctl restart cron.service