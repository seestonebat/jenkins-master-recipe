#!/bin/bash

# This script installs jenkins on bare instances

RUN_DIR=$(cd $(dirname $0) && pwd)

# Exit on any failure
set -e

# Exiti if jenkins laready present
if dpkg-query -l jenkins > /dev/null ; then 
    echo "ERROR: Jenkins is already installed"
    exit 1
fi

# Install jenkins package
wget -q -O - https://jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -
sudo sh -c 'echo deb http://pkg.jenkins-ci.org/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
sudo apt-get update
sudo apt-get install --assume-yes jenkins

# Forward port 8080 to 80
sudo perl -0777 -i.original -pe 's/^exit 0/#Requests from outside\niptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-ports 8080
\n#Requests from localhost\niptables -t nat -I OUTPUT -p tcp -d 127.0.0.1 --dport 80 -j REDIRECT --to-ports 8080\nexit 0/igs' /etc/rc.local
sudo /etc/rc.local

# FIXME - this hardcoded sleep should be replaced by an incremental backoff
sleep 5
echo "************ SUCCESSFULLY INSTALLED JENKINS *********************"
exit 0
