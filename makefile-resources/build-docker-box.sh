#!/bin/bash

echo "Init packer build for Docker $CURRENT_DOCKER_VERSION version and $PROVIDER as provider"
cd packer; packer build -var "docker_version=$CURRENT_DOCKER_VERSION" -var "debian_version=$CURRENT_DEBIAN_VERSION" -var "output_directory=$PACKER_DIRECTORY_OUTPUT" -only builder.$PROVIDER-iso.docker packer.pkr.hcl