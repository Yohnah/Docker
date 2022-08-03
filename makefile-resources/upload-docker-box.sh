#!/bin/bash

if [[ "$PROVIDER" == *"vmware"* ]];
then
    HyperVisor="vmware_desktop"
else
    HyperVisor=$PROVIDER
fi

export DATETIME=$(date "+%Y-%m-%d %H:%M:%S")

BOXFILE=$(cat /tmp/packer-build/$CURRENT_DOCKER_VERSION/manifest.json | jq '.builds | .[].files | .[].name' | grep "$CURRENT_DOCKER_VERSION" | grep "$PROVIDER" | sed 's/"//g' | uniq)

echo "Box $BOXFILE found, uploading..." 
vagrant cloud version update -d "$(cat ./makefile-resources/uploading-box-notification-template.md | envsubst)" Yohnah/Docker $CURRENT_DOCKER_VERSION
vagrant cloud provider delete -f Yohnah/Docker $HyperVisor $CURRENT_DOCKER_VERSION || true
SHASUM=$(shasum $BOXFILE | awk '{ print $1 }')
vagrant cloud provider create --timestamp --checksum-type sha1 --checksum $SHASUM Yohnah/Docker $HyperVisor $CURRENT_DOCKER_VERSION
vagrant cloud provider upload Yohnah/Docker $HyperVisor $CURRENT_DOCKER_VERSION $BOXFILE
vagrant cloud version update -d "$(cat ./makefile-resources/box-version-description-template.md | envsubst)" Yohnah/Docker $CURRENT_DOCKER_VERSION
echo "Box $BOXFILE uploaded"