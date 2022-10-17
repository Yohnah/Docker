#!/bin/bash

echo "Installing docker"
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update

sudo apt-get -y install docker-ce docker-ce-cli containerd.io

sudo mkdir -p /etc/systemd/system/docker.service.d

cat <<EOF | sudo tee /etc/systemd/system/docker.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375
EOF

sudo adduser vagrant docker

sudo mv /tmp/install-docker-cli.sh /usr/local/bin
sudo chmod +x /usr/local/bin/install-docker-cli.sh

sudo mv /tmp/uninstall-docker-cli.sh /usr/local/bin
sudo chmod +x /usr/local/bin/uninstall-docker-cli.sh