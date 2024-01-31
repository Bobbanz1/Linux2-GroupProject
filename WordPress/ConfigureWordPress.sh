#!/bin/bash

if [ "$USER" != "root" ]
then
    echo "This script needs to run by using sudo, please try again!"
    exit 2
fi

# Installing WP-CLI
curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar

# Makes the new file runnable
chmod +x wp-cli.phar

# Moves it into the /usr/local/bin folder with the name of wp
mv wp-cli.phar /usr/local/bin/wp

# Changes directory to the one with the wordpress installation
if [ -e /srv/www/wordpress ]
then
    cd /srv/www/wordpress
else
    echo "Problems occured during installation, please try again!"
    exit 2
fi

# Create administrator account
echo "Creating WordPress Administrator: foxfire, Linux4Ever"
#sudo -u www-data wp user create foxfire foxfire@gmail.com --role=administrator --user_pass=Linux4Ever
sudo -u www-data wp core install --path=/srv/www/wordpress --url=localhost --title=Foxfire --admin_user=foxfire --admin_password=Linux4Ever --admin_email=foxfire@gmail.com

# Installs and activates the plugin allowing for connecting to OpenLDAP
sudo -u www-data wp plugin install authldap --activate
