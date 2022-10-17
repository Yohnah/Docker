DOCKER_VERSION=$(docker -v | awk '{ print $3 }' | sed 's/,//g')
BIN_DIR="/vagrant/bin"

rm -fr $BIN_DIR

cat <<-EOF

Docker client binary was uninstalled

EOF