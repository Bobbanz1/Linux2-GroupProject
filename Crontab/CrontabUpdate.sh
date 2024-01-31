#!/bin/bash

echo "Startar Autopackage Uppdatering"
echo "Tiden är $(date +%Y%m%d)"
apt-get update

apt-get upgrade -y
echo " "