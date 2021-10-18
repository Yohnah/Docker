#!/bin/bash

echo "Installing docker version $VERSION"
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt-get update

DOCKER_VERSION=$(apt-cache madison docker-ce | grep -i "20.10.9" | awk -F\| '{ print $2 }' | tr -d '[:space:]')
sudo apt-get -y install docker-ce=$DOCKER_VERSION docker-ce-cli=$DOCKER_VERSION containerd.io

sudo mkdir -p /etc/systemd/system/docker.service.d

cat <<EOF | sudo tee /etc/systemd/system/docker.service.d/override.conf
[Service]
ExecStart=
ExecStart=/usr/bin/dockerd -H fd:// -H tcp://0.0.0.0:2375
EOF

echo "Downloading docker client binary packages for version $VERSION"
sudo mkdir -p /opt/packages/{win,mac,linux}
sudo chmod -R 777 /opt/packages

echo "Downloading Windows Docker Cli: https://download.docker.com/win/static/stable/x86_64/docker-$VERSION.zip"
curl -o /opt/packages/win/docker-cli.zip https://download.docker.com/win/static/stable/x86_64/docker-$VERSION.zip
echo "Downloading MacOS Docker Cli: https://download.docker.com/mac/static/stable/x86_64/docker-$VERSION.tgz"
curl -o /opt/packages/mac/docker-cli.tgz https://download.docker.com/mac/static/stable/x86_64/docker-$VERSION.tgz
echo "Downloading Linux Docker Cli: https://download.docker.com/linux/static/stable/x86_64/docker-$VERSION.tgz"
curl -o /opt/packages/linux/docker-cli.tgz https://download.docker.com/linux/static/stable/x86_64/docker-$VERSION.tgz

mv /tmp/docker-cli-{unin,in}staller.cmd /opt/packages/win/
cp /tmp/docker-cli-{unin,in}staller.sh /opt/packages/mac/
mv /tmp/docker-cli-{unin,in}staller.sh /opt/packages/linux/