#!/usr/bin/env bash

# Install and deploy a Globus connect server on a GCP instance

# print commands and their expanded arguments
set -x

# Fail out if anything goes wrong
set -e

# Instructions for installing GCS from: 
# https://docs.globus.org/globus-connect-server/v5.4/#globus_connect_server_prerequisites
update-locale LANG=C.UTF-8

mkdir -p /opt/software && cd /opt/software
curl -LOs https://downloads.globus.org/globus-connect-server/stable/installers/repo/deb/globus-repo_latest_all.deb
sudo dpkg -i globus-repo_latest_all.deb
sudo apt-key add /usr/share/globus-repo/RPM-GPG-KEY-Globus
sudo apt update
sudo apt install -y globus-connect-server54

# Also install ntp/ntpstat
apt-get install -y ntp ntpstat
service ntp start
