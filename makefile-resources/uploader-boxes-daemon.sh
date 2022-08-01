#!/bin/bash

while true;
do
    ls $UPLOADER_DIRECTORY/*.box 2> /dev/null | while read FILE;
    do

        export DATETIME=$(date "+%Y-%m-%d %H:%M:%S")
        FILENAME=$(basename $FILE)
        DOCKER_VERSION=$(echo "$FILENAME" | sed 's/\.box//g' | awk -F- '{ print $2 }')
        export DEBIAN_VERSION=$(echo "$FILENAME" | sed 's/\.box//g' | awk -F- '{ print $4 }')
        export PROVIDER=$(echo "$FILENAME" | sed 's/\.box//g' | awk -F- '{ print $3 }')
        echo "Box $FILE found, uploading..." 
        vagrant cloud version update -d "$(cat ./makefile-resources/uploading-box-notification-template.md | envsubst)" Yohnah/Docker $DOCKER_VERSION
        vagrant cloud provider upload Yohnah/Docker $PROVIDER $DOCKER_VERSION $FILE
        vagrant cloud version update -d "$(cat ./makefile-resources/box-version-description-template.md | envsubst)" Yohnah/Docker $DOCKER_VERSION
        echo "Box $FILE uploaded"
        rm -fr $FILE
    done

    if [[ -f "/tmp/packer-build/toupload/done" && "$(ls /tmp/packer-build/toupload/*.box 2> /dev/null | wc -l)" -eq "0" ]];
    then
        echo "No more boxes to upload"
        break
    fi

    echo "Waiting for more boxes to upload"
    sleep 10

done
exit 0