#!/bin/sh
echo "Configured IP addresses: "
ip -4 addr show | grep -i 'eth' | grep -i 'inet' | awk '{ print $NF": "$2 }'