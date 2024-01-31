#!/bin/bash

set -e

BACKUP_PATH=/var/backups/ldap
SLAPCAT=/usr/sbin/slapcat
if [ ! -e $BACKUP_PATH ]; then
    mkdir /var/backups/ldap
fi

nice ${SLAPCAT} -b cn=config > ${BACKUP_PATH}/$(date +%Y%m%d)_config.ldif
nice ${SLAPCAT} -b dc=foxfire,dc=se > ${BACKUP_PATH}/$(date +%Y%m%d)_foxfire.se.ldif
chown root:root ${BACKUP_PATH}/*
chmod 600 ${BACKUP_PATH}/*.ldif