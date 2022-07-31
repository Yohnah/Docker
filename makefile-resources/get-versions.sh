#!/bin/bash

case $TYPE in
    current_docker_version)
        curl -s https://docs.docker.com/engine/release-notes/ | grep -i "nomunge" | grep -v "Version" | grep -v "<ul>" | head -n 1 | sed -e 's/<[^>]*>//g' | sed 's/ //g'
    ;;
    current_debian_version)
        curl -s https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/ | grep -oE "debian-(.*)-amd64-netinst.iso" | sed -e 's/<[^>]*>//g' | cut -d">" -f 1 | sed 's/"//g' | head -n 1 | cut -d- -f2
    ;;
    current_box_version)
        curl -sS "https://app.vagrantup.com/api/v1/box/Yohnah/Docker" | jq '.current_version.version'
    ;;
    all_docker_releases)
        curl -s https://docs.docker.com/engine/release-notes/ | grep -i 'nomunge' | grep -v 'Version' | grep -v '<ul>' | sed -e 's/<[^>]*>//g' | sed 's/ //g' | jq -ncR '[inputs]' | sed 's/"/\\"/g'
    ;;
    checkifbuild)
        if [ "$CURRENT_DOCKER_VERSION" = "$CURRENT_BOX_VERSION" ]; then
            echo "false"
        else
            echo "true"
        fi
    ;;
esac

exit 0