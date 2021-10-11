#!/bin/sh

echo "Cleaning cache"
sudo apk -v cache clean

echo "Zeroing disk"
dd if=/dev/zero of=/tmp/ERASE bs=1M | true

echo "Removing zeroing file"
rm -f /tmp/ERASE
