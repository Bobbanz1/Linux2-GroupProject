#!/bin/bash

# Purpose of Script: Used to create backups of the Database used by WordPress

mkdir -p /var/backups/mysql/"$(date +%Y)"/"$(date +%m)"/

mysqldump -u wordpress --password=Linux4Ever GroupProject > /var/backups/mysql/"$(date +%Y)"/"$(date +%m)"/"$(date +%d)_GroupProject.sql"