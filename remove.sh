#!/bin/bash

set -e

sudo dpkg  --purge jenkins
sudo mv /etc/rc.local.original /etc/rc.local

echo "******************************* JENKINS SUCCESSFULLY REMOVED *******************************"
return 0
