#!/bin/bash

if [[ "$PROVIDER" == *"vmware"* ]];
then
    export HyperVisor = "vmware"
else
    export HyperVisor = $PROVIDER
fi

BOXFILE=$(cat /tmp/packer-build/$CURRENT_DOCKER_VERSION/manifest.json | jq '.builds | .[].files | .[].name' | grep "$CURRENT_DOCKER_VERSION" | grep "$HyperVisor" | sed 's/"//g' | uniq)

echo "boxfile es $BOXFILE"

vagrant box add --provider $PROVIDER -f --name "testing-docker-box-$CURRENT_DOCKER_VERSION" $BOXFILE
cd $PACKER_DIRECTORY_OUTPUT/test/$CURRENT_DOCKER_VERSION/$PROVIDER
vagrant init 'testing-docker-box-'$CURRENT_DOCKER_VERSION
vagrant up --provider $PROVIDER
vagrant provision
#DOCKER_HOST="tcp://$(vagrant ssh-config | grep -i "HostName" | awk '{ print $2 }'):$(vagrant port --guest 2375)/" $HOME/.Yohnah/Docker/docker run hello-world;
vagrant destroy -f

rm -fr $PACKER_DIRECTORY_OUTPUT/test/$CURRENT_DOCKER_VERSION/$PROVIDER/*
vagrant box remove "testing-docker-box-$CURRENT_DOCKER_VERSION" --provider $PROVIDER

if [[ "$?" -eq 0 ]];
then
    echo "Everythings was ok... moving to upload the box"
    mv $BOXFILE $UPLOADER_DIRECTORY/docker-$CURRENT_DOCKER_VERSION-$HyperVisor-$CURRENT_DEBIAN_VERSION.box
fi
