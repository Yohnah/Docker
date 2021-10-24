#!/bin/sh

KIND_OF_SHELL=$(echo $SHELL | awk -F/ '{ print $NF }')
PROFILE_FILE="$HOME/.profile"
YOHNAH_PATH="$HOME/.Yohnah"
DOCKER_PATH="$YOHNAH_PATH/Docker"
YOHNAH_ENVS_PATH="$YOHNAH_PATH/Envs"

CURRENT_DIR=$(dirname "$(pwd)/$0")

SERVICE_IP="<ip address to parser>"

VAGRANT_HOSTNAME=$(vagrant ssh-config | grep -i "HostName" | awk '{ print $2 }')
VAGRANT_PORT=$(vagrant port --guest 2375)

function main (){
    check_shell
    mkdir_yohnah_docker_dir
    install_docker_cli
    set_environment_variables
}

function mkdir_yohnah_docker_dir(){
    echo "Creating Yohnah folders at $YOHNAH_PATH"
    mkdir -p $YOHNAH_PATH
    mkdir -p $DOCKER_PATH
    mkdir -p $YOHNAH_ENVS_PATH
}

function install_docker_cli(){
    echo "Installing docker client binary"
    cp -R $CURRENT_DIR/docker/* $DOCKER_PATH
}

function set_environment_variables(){
    code_to_dump='ls $HOME/.Yohnah/envs/*.env | while read FILE; do . $FILE; done'
    grep -Fxq "$code_to_dump" $PROFILE_FILE
    if [[ $? == 1 ]]; then
        echo "Configuring $PROFILE_FILE"
        echo "#" >> $PROFILE_FILE
        echo "# Added $KIND_OF_SHELL code by a Yohnah vagrant box" >> $PROFILE_FILE
        echo $code_to_dump >> $PROFILE_FILE
    fi
    touch $YOHNAH_ENVS_PATH/control.env
    echo 'export PATH=$PATH:'$DOCKER_PATH > $YOHNAH_ENVS_PATH/yohnah_docker_path.env
    echo "export DOCKER_HOST=tcp://$VAGRANT_HOSTNAME:$VAGRANT_PORT" > $YOHNAH_ENVS_PATH/yohnah_docker_host.env
    echo "Docker service running at tcp://$VAGRANT_HOSTNAME:$VAGRANT_PORT"
}

function check_shell(){
    case $KIND_OF_SHELL in
        bash)
            PROFILE_FILE="$HOME/.bashrc"
        ;;
        zsh)
            PROFILE_FILE="$HOME/.zshrc"
        ;;
        ash)
            PROFILE_FILE="$HOME/.profile"
        ;;
        ksh)
            PROFILE_FILE="$HOME/.kshrc"
        ;;
    esac

echo "Detected shell profile file $PROFILE_FILE"
}

main
