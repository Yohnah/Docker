#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

echo "Updating SO"
sudo apt-get update
sudo apt-get -y dist-upgrade
sudo apt-get -y install lsb-release adduser unzip

echo "Replacing motd message"
cat /tmp/motd | sudo tee /etc/motd
sudo chmod 644 /etc/motd 
sudo rm -f /tmp/motd

echo "Installing scripts"
sudo mv /tmp/get-ips.sh /usr/bin/
chmod +x /usr/bin/get-ips.sh

sudo mv /tmp/deploy-docker-files.sh /usr/bin/
chmod +x /usr/bin/deploy-docker-files.sh