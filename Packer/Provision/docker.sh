#!/bin/sh

echo "Installing docker"
sudo apk add docker

echo "Allowing external client docker connections"
sudo sed -i 's&DOCKER_OPTS=""&DOCKER_OPTS="-H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock"&g' /etc/conf.d/docker

echo "Vegrant becomes a docker member"
sudo adduser vagrant docker

echo "Enabling docker on boot"
sudo rc-update add docker boot

echo "Check if docker start"
sudo service docker start

