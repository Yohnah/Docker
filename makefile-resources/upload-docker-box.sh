#!/bin/bash

export DATETIME=$(date "+%Y-%m-%d %H:%M:%S")

echo "Box $FILE found, uploading..." 
vagrant cloud version update -d "$(cat ./makefile-resources/uploading-box-notification-template.md | envsubst)" Yohnah/Docker $CURRENT_DOCKER_VERSION
vagrant cloud provider upload Yohnah/Docker $PROVIDER $CURRENT_DOCKER_VERSION $FILE
vagrant cloud version update -d "$(cat ./makefile-resources/box-version-description-template.md | envsubst)" Yohnah/Docker $CURRENT_DOCKER_VERSION
echo "Box $FILE uploaded"