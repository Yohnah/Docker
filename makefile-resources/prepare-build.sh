#!/bin/bash -x
cp Packer/vagrantfile.rb Debian/Packer/vagrantfile.rb

cp -R Packer/scripts-to-run/* Debian/Packer/scripts-to-run

cp -R Packer/files-to-upload/* Debian/Packer/files-to-upload/