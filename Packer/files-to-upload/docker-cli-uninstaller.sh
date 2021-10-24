#!/bin/sh

YOHNAH_PATH="$HOME/.Yohnah"
DOCKER_PATH="$YOHNAH_PATH/Docker"
YOHNAH_ENVS_PATH="$YOHNAH_PATH/Envs"

echo "Unconfiguring and uninstalling docker client"
rm -fr $DOCKER_PATH
rm -f $YOHNAH_ENVS_PATH/yohnah_docker_path.env
rm -f $YOHNAH_ENVS_PATH/yohnah_docker_host.env