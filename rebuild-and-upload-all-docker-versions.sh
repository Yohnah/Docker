#!/bin/bash

ALL_DOCKER_VERSIONS=$(curl -s https://docs.docker.com/engine/release-notes/ | grep -i 'nomunge' | grep -v 'Version' | grep -v '<ul>' | sed -e 's/<[^>]*>//g' | sed 's/ //g')

echo $ALL_DOCKER_VERSIONS | sed "s/ /\n/g" | while read VERSION;
do
    make version CURRENT_DOCKER_VERSION=$VERSION
    make build CURRENT_DOCKER_VERSION=$VERSION
    make test
    make upload
    make clean
done