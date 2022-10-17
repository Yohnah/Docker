DOCKER_VERSION=$(docker -v | awk '{ print $3 }' | sed 's/,//g')
BIN_DIR="/vagrant/bin"
mkdir -p $BIN_DIR


case "$HOST_OS" in
        "win")
            wget -O $BIN_DIR/docker-cli.zip https://download.docker.com/win/static/stable/x86_64/docker-$DOCKER_VERSION.zip
            unzip -o $BIN_DIR/docker-cli.zip -d $BIN_DIR
        ;;
        "mac")
            wget -O $BIN_DIR/docker-cli.tgz https://download.docker.com/mac/static/stable/x86_64/docker-$DOCKER_VERSION.tgz
            tar -xzvf $BIN_DIR/docker-cli.tgz -C $BIN_DIR
        ;;
        "linux")
            wget -O $BIN_DIR/docker-cli.tgz https://download.docker.com/linux/static/stable/x86_64/docker-$DOCKER_VERSION.tgz
            tar -xzvf $BIN_DIR/docker-cli.tgz -C $BIN_DIR
        ;;
esac

cat <<-EOF


Docker client binaries were installed in ./bin/docker/ directory within your vagrant workspace. Just define a new docker context to setup
your docker client, ex:

$ ./bin/docker/docker context create vagrant --docker host=tcp://127.0.0.1:2375
$ ./bin/docker/docker context use vagrant

or run:

$ export DOCKER_HOST="tcp://127.0.0.1:2375" #or setx DOCKER_HOST tcp://127.0.0.1:2375 on Windows

and, then:

$ ./bin/docker/docker run hello-world

EOF
