#!/bin/bash

#=======================#
# Bash script to install and configure WordPress
#
# Things that needs done
# [X] Automate installation of all required components for Wordpress
# [X] Minor automated configurations for WordPress
#=======================#

apt-get -o DPkg::Lock::Timeout=300 update

# Install dependencies for WordPress
apt-get -o DPkg::Lock::Timeout=300 -y install apache2 \
                 ghostscript \
                 libapache2-mod-php \
                 mysql-server \
                 php \
                 php-bcmath \
                 php-curl \
                 php-imagick \
                 php-intl \
                 php-json \
                 php-mbstring \
                 php-mysql \
                 php-xml \
                 php-zip \
				 php-ldap \
				 curl

# If the folder doesnt exist then create it, otherwise skip.
if [ ! -e /srv/www ]; then
	mkdir -p /srv/www
	
	# Sets the /srv/www folder as being owned by www-data.
	chown www-data: /srv/www
fi

# Downloads and installs wordpress into the /srv/www folder.
curl https://wordpress.org/latest.tar.gz | sudo -u www-data tar zx -C /srv/www

# Used to grab the folder where sites are stored.
fileToCheck=/etc/apache2/sites-available

# Checks if the folder exists otherwise it returns an error.
# If the folder exists then it creates a wordpress.conf file with all the configurations for the website
if [ -e $fileToCheck ]
then
	echo "Creating Apache site for WordPress"
	echo "
<VirtualHost *:80>
	DocumentRoot /srv/www/wordpress
	<Directory /srv/www/wordpress>
		Options FollowSymLinks
		AllowOverride Limit Options FileInfo
		DirectoryIndex index.php
		Require all granted
	</Directory>
	<Directory /srv/www/wordpress/wp-content>
		Options FollowSymLinks
		Require all granted
	</Directory>
</VirtualHost>" > $fileToCheck/wordpress.conf

else 
	echo "Error, something went wrong during installation /etc/apache2/sites-available doesn't exist!"
	exit 2
fi

a2ensite wordpress

a2enmod rewrite

a2dissite 000-default

phpenmod ldap

service apache2 reload
