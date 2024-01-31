#!/bin/bash

# Creates an sql file which will create our only user in this database
echo "create database if not exists GroupProject;
create user wordpress@localhost identified by 'Linux4Ever';
grant all privileges on GroupProject.* to wordpress@localhost;
grant process on *.* to wordpress@localhost;" > tempdb1.sql

# Conditional to ensure that if the file somehow never got created we won't have runtime errors
if [ ! -e tempdb1.sql ]; then
    echo "Error, file doesn't exist, terminating script."
    exit 2
fi

# Starts MySQL
service mysql start

# Imports the file into MySQL which creates the database
mysql <tempdb1.sql

# Copies the sample file and presses it into service.
sudo -u www-data cp /srv/www/wordpress/wp-config-sample.php /srv/www/wordpress/wp-config.php

# Configures the config file to connect to the database
sudo -u www-data sed -i 's/database_name_here/GroupProject/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/username_here/wordpress/' /srv/www/wordpress/wp-config.php
sudo -u www-data sed -i 's/password_here/Linux4Ever/' /srv/www/wordpress/wp-config.php
