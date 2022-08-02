#!/bin/bash

if [[ "$PROVIDER" == *"vmware"* ]];
then
    HyperVisor="vmware_desktop"
else
    HyperVisor=$PROVIDER
fi

BOXFILE=$(cat /tmp/packer-build/$CURRENT_DOCKER_VERSION/manifest.json | jq '.builds | .[].files | .[].name' | grep "$CURRENT_DOCKER_VERSION" | grep "$PROVIDER" | sed 's/"//g' | uniq)

echo "Removing $BOXFILE box"
rm -fr $BOXFILE