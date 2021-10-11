#!/bin/sh

echo "Updating SO"
sudo apk update
sudo apk upgrade

echo "Replacing motd message"
cat /tmp/motd | sudo tee /etc/motd
sudo chmod 644 /etc/motd 
sudo rm -f /tmp/motd