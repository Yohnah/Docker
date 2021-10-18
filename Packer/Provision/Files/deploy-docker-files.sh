#!/bin/bash

OSHOST=$1
HYPERVISOR=$2
INSTALL_DIR="/vagrant/installer"

SERVICE_IP=$(ip -4 addr | grep "eth" | grep "inet" | awk '{ print $2 }' | head -n 2 | tail -n 1 | awk -F/ '{ print $1 }')

mount | grep -i "/vagrant" > /dev/null
if [[ $? == "1" ]]; then
        echo "/vagrant dir not mounted"
        exit 1
fi

mkdir -p $INSTALL_DIR

rm -fr $INSTALL_DIR/*

echo "Uncompress docker cli binary for $OSHOST operative system to /vagrant/install/"

case "$OSHOST" in
        "win")
                unzip -o /opt/packages/win/docker-cli.zip -d $INSTALL_DIR
                cp /opt/packages/win/docker-cli-{unin,in}staller.cmd $INSTALL_DIR
        ;;
        "mac")
                tar -xzvf /opt/packages/mac/docker-cli.tgz -C $INSTALL_DIR
                cp /opt/packages/mac/docker-cli-{unin,in}staller.sh $INSTALL_DIR
        ;;
        "linux")
                tar -xzvf /opt/packages/linux/docker-cli.tgz -C $INSTALL_DIR
                cp /opt/packages/linux/docker-cli-{unin,in}staller.sh $INSTALL_DIR
        ;;
esac


echo "Detected hypervisor as $HYPERVISOR"

case "$HYPERVISOR" in
        "hyperv")
                echo "Fixing docker-cli-installer script for hyperv hypervisor"
                sed -i "s#for /f \"tokens=2\" %%h in ('vagrant ssh-config ^|findstr \"HostName\"') do ( SET vagrant_hn=%%h)#set vagrant_hn=$SERVICE_IP#g" $INSTALL_DIR/docker-cli-installer.cmd
                sed -i "s#for /f \"tokens=1\" %%b in ('vagrant port --guest 2375') do ( SET vagrant_port=%%b)#set vagrant_port=2375#g" $INSTALL_DIR/docker-cli-installer.cmd
        ;;
esac

sed -i "s/<ip address to parser>/$SERVICE_IP/g" $INSTALL_DIR/docker-cli-installer.*