#!/bin/bash

#=======================#
# OpenLDAP Installation and Configuration Script
# Needs to be ran through sudo for it to function correctly, will alert the user to it.
#
# [X] Make this stuff get sent to a log file
# [X] Make the script function correctly
# [X] Make it install JXplorer as well
#=======================#

# Defines
LOGFILE=/var/log/openldapinstall.log

# Early Checks
if [ "$USER" != "root" ]; then
	echo "This script needs to run by using sudo, please try again!"
	exit 2
fi

if [ ! -f $LOGFILE ]; then
    echo "Creating Log File, installation log can be found in /var/log/openldapinstall.log"
    touch $LOGFILE
fi

# Script
echo "Installation Log can be found in /var/log/openldapinstall.log"

echo "
#===============================================#
Start date/time is: $(date '+%Y-%m-%d %H:%M:%S')

Running Installation!
#===============================================#" | tee -a $LOGFILE

echo "Changing Host Name to ldap.foxfire.se" | tee -a $LOGFILE
hostnamectl set-hostname ldap.foxfire.se

echo "Updating /etc/hosts file with server name and IP address for hostname resolution" | tee -a $LOGFILE
echo "Please input the IP-Address you want to be used to reach the server from."
read -r IPADDRESS

echo "Selected IP Address for ldap.foxfire.se: $IPADDRESS" >>$LOGFILE

echo "$IPADDRESS ldap.foxfire.se" >> /etc/hosts

echo "Pinging to check if change has been done successfully" | tee -a $LOGFILE
ping -c 3 ldap.foxfire.se | tee -a $LOGFILE

# Creates file containing all the configurations we need to have done when we install slapd
cat > /root/debconf-slapd.conf << 'EOF'
slapd slapd/root_password password admin
slapd slapd/root_password_again password admin
slapd slapd/internal/adminpw password admin
slapd slapd/internal/generated_adminpw password admin
slapd slapd/password2 password admin
slapd slapd/password1 password admin
slapd slapd/domain string foxfire.se
slapd shared/organization string foxfire.se
slapd slapd/backend string HDB
slapd slapd/purge_database boolean false
slapd slapd/move_old_database boolean true
slapd slapd/allow_ldap_v2 boolean false
slapd slapd/no_configuration boolean false
EOF

# Temporarily makes it so installing openldap and configuring it doesn't require interactions
#export DEBIAN_FRONTEND='noninteractive'

# Pushes the configurations into debconf so we won't encounter any screens that would have required our interaction.
debconf-set-selections < /root/debconf-slapd.conf

echo "Script is still running, it may take some time for the installation to finish, please hold until the next message. If it hasn't appeared in approximately 20 minutes then something has gone wrong and you are free to terminate the script!"

# Install the slapd and ldap-utils packages
DEBIAN_FRONTEND=noninteractive apt-get -o DPkg::Lock::Timeout=300 install -y slapd ldap-utils >>$LOGFILE

echo "Package Installation complete, configuring them now!"

# Sets up the slapd package and configures it.
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure slapd >>$LOGFILE

echo "Configuration Completed!"

if [ ! -f /etc/ldap/ldap.conf ]; then
    echo "Error, problem occured while installing, ldap.conf is missing!" | tee -a $LOGFILE
    echo "Script terminated with errors at $(date '+%Y-%m-%d %H:%M:%S')" | tee -a $LOGFILE
    exit 2
fi

echo "Cleaning up used config file from installation" >>$LOGFILE
rm /root/debconf-slapd.conf

chmod 777 /etc/ldap/ldap.conf

cat <<'EOF' > /etc/ldap/ldap.conf
#
# LDAP DEFAULTS
#

# See ldap.conf(5) for details
# This file should be world readable but not world writable.

BASE    dc=foxfire,dc=se
URI     ldap://ldap.foxfire.se ldap://ldap-provider.foxfire.se:666

#SIZELIMIT      12
#TIMELIMIT      15
#DEREF          never

# TLS certificates (needed for GnuTLS)
TLS_CACERT      /etc/ssl/certs/ca-certificates.crt
EOF

chmod 744 /etc/ldap/ldap.conf

# Clean-up, resets DEBIAN_FRONTEND to default.
#export DEBIAN_FRONTEND='newt'

systemctl restart slapd

# Late Define, used to ensure that the password is salted correctly so the admin can actually log in, very unsecure since it's hard coded but ehhhh.
PASS_ME_SALT=$(slappasswd -h {SHA} -s admin)

echo "dn: olcDatabase={0}config,cn=config
changetype: modify
add: olcRootPW
olcRootPW: $PASS_ME_SALT" > rootpw.ldif

ldapadd -Y EXTERNAL -H ldapi:/// -f rootpw.ldif >>$LOGFILE

# Cleans up by removing the rootpw.ldif file
rm rootpw.ldif

echo "dn:olcDatabase={1}mdb,cn=config
changetype: modify
replace: olcSuffix
olcSuffix: dc=foxfire,dc=se

dn: olcDatabase={1}mdb,cn=config
changetype: modify
replace: olcRootDN
olcRootDN: cn=admin,dc=foxfire,dc=se

dn: olcDatabase={1}mdb,cn=config
changetype: modify
replace: olcRootPW
olcRootPW: $PASS_ME_SALT" > admin.ldif

ldapmodify -Y EXTERNAL -H ldapi:/// -f admin.ldif >>$LOGFILE

# Cleans up by removing the admin.ldif file
rm admin.ldif

ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// >>$LOGFILE

# Makes an ldif file that contains the current basic orgizationalUnits
cat << 'EOF' > base-groups.ldif
dn: ou=people,dc=foxfire,dc=se
objectClass: organizationalUnit
ou: people

dn: ou=groups,dc=foxfire,dc=se
objectClass: organizationalUnit
ou: groups
EOF

# Adds the orgizationalUnits to the directory
ldapadd -x -D cn=admin,dc=foxfire,dc=se -w admin -f base-groups.ldif >>$LOGFILE

ldapsearch -Q -LLL -Y EXTERNAL -H ldapi:/// >>$LOGFILE

# Cleans up by removing the user.ldif file
rm base-groups.ldif

# File that contains information for adding a new group to the groups orgizationalUnit.
cat << 'EOF' > group.ldif
dn: cn=editor,ou=groups,dc=foxfire,dc=se
objectClass: posixGroup
cn: editor
gidNumber: 5000

dn: cn=author,ou=groups,dc=foxfire,dc=se
objectClass: posixGroup
cn: author
gidNumber: 5001

dn: cn=contributor,ou=groups,dc=foxfire,dc=se
objectClass: posixGroup
cn: contributor
gidNumber: 5002
EOF

# Adds the only group we currently have to the groups orgizationalUnit
ldapadd -x -D cn=admin,dc=foxfire,dc=se -w admin -f group.ldif >>$LOGFILE

# Cleans up by removing the group.ldif file
rm group.ldif

# Used to see if it worked or not.
ldapsearch -x -LLL -b dc=foxfire,dc=se '(cn=editor)' gidNumber >>$LOGFILE

# Makes a file that contains information for creating a single user for the openLDAP
cat << 'EOF' > user.ldif
dn: uid=alex,ou=people,dc=foxfire,dc=se
objectClass: inetOrgPerson
objectClass: posixAccount
objectClass: shadowAccount
uid: alex
sn: smith
givenName: alex
cn: alex smith
displayName: alex smith
uidNumber: 7000
gidNumber: 7000
userPassword: Linux4Ever
gecos: Alex Smith
loginShell: /bin/bash
homeDirectory: /home/alex
EOF

ldapadd -x -D cn=admin,dc=foxfire,dc=se -w admin -f user.ldif >>$LOGFILE

ldapsearch -x -LLL -b dc=foxfire,dc=se '(uid=alex)' cn uidNumber gidNumber >>$LOGFILE

# Cleans up by removing the user.ldif file
rm user.ldif

# Installing JXplorer, the thing we're using to manage the LDAP without having to use the CLI
apt-get -q install -y jxplorer >>$LOGFILE

echo "
#===============================================#
Script Completed at date/time: $(date '+%Y-%m-%d %H:%M:%S')

Installation Complete!
#===============================================#" >>$LOGFILE
