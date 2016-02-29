#!/bin/bash

set -e

if ! sudo service jenkins status > /dev/null; then
    echo "ERROR: JENKINS SERVER IS NOT RUNNING. PLEASE START IT AND THEN RUN UPDATE AGAIN"
    exit 1
fi
 
# Create a scratch directory
SCRATCH_DIR=$(dirname $0)/scratch
rm -rf $SCRATCH_DIR
mkdir  $SCRATCH_DIR
pushd $SCRATCH_DIR > /dev/null

# Retrieve the jenkins cli jar fro the running instance
wget --quiet http://127.0.0.1/jnlpJars/jenkins-cli.jar

# Install the ec2 autoscale plugin
java -jar jenkins-cli.jar -s http://127.0.0.1:8080/ install-plugin ec2
popd > /dev/null

if [[ -z $JENKINS_HOME ]] ; then 
	JENKINS_HOME=/var/lib/jenkins
fi 

# Update master  config if needed.
if ! cmp jenkins_master_config $JENKINS_HOME/config.xml ; then
    sudo service jenkins stop
    echo "INFO: Change found in jenkins master config. Updating it."
    sudo cp jenkins_master_config $JENKINS_HOME/config.xml
    sudo service jenkins start
fi

rm -rf $SCRATCH_DIR 
echo "SUCCESS:  Jenkins successfully updated."
echo "          Please manually add the EC2 access key ID, Secret Access Key and"
echo "           Key Pair Private Key into the ec2 plugin config."
exit 0
