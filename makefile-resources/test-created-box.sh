#!/bin/bash

if [[ "$PROVIDER" == *"vmware"* ]];
then
    HyperVisor="vmware_desktop"
else
    HyperVisor=$PROVIDER
fi

BOXFILE=$(cat /tmp/packer-build/$CURRENT_DOCKER_VERSION/manifest.json | jq '.builds | .[].files | .[].name' | grep "$CURRENT_DOCKER_VERSION" | grep "$PROVIDER" | sed 's/"//g' | uniq)

echo "Testing $BOXFILE box for $HyperVisor provider"

vagrant box add --provider $HyperVisor -f --name "testing-docker-box-$CURRENT_DOCKER_VERSION-$PROVIDER" $BOXFILE
cd $PACKER_DIRECTORY_OUTPUT/test/$CURRENT_DOCKER_VERSION/$PROVIDER
vagrant init "testing-docker-box-$CURRENT_DOCKER_VERSION-$PROVIDER"
vagrant up --provider $HyperVisor
vagrant provision
vagrant ssh -- 'docker run hello-world'
#DOCKER_HOST="tcp://$(vagrant ssh-config | grep -i "HostName" | awk '{ print $2 }'):$(vagrant port --guest 2375)/" $HOME/.Yohnah/Docker/docker run hello-world;
vagrant destroy -f

cd; rm -fr $PACKER_DIRECTORY_OUTPUT/test/$CURRENT_DOCKER_VERSION/$PROVIDER/*
vagrant box remove "testing-docker-box-$CURRENT_DOCKER_VERSION-$PROVIDER" --provider $HyperVisor
