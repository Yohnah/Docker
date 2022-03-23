CURRENT_BOX_VERSION := $(subst ", ,$(shell curl -sS "https://app.vagrantup.com/api/v1/box/Yohnah/Docker" | jq '.current_version.version'))
CURRENT_DOCKER_VERSION := $(shell curl -s https://docs.docker.com/engine/release-notes/ | grep -i "nomunge" | grep -v "Version" | grep -v "<ul>" | head -n 1 | sed -e 's/<[^>]*>//g' | sed 's/ //g')
CURRENT_DEBIAN_VERSION := $(shell curl -s https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/ | grep -oE "debian-(.*)-amd64-netinst.iso" | sed -e 's/<[^>]*>//g' | cut -d">" -f 1 | sed 's/"//g' | head -n 1 | cut -d- -f2)
OUTPUT_DIRECTORY := /tmp
DATETIME := $(shell date "+%Y-%m-%d %H:%M:%S")

.PHONY: all version build test clean_test upload clean

all: version build test

version: 
	@echo "========================="
	@echo Current Docker Version: $(CURRENT_DOCKER_VERSION)
	@echo Current Box Version: $(CURRENT_BOX_VERSION)
	@echo Current Debian Version: $(CURRENT_DEBIAN_VERSION)
	@echo "========================="
	@echo ""

build:
ifeq ($(CURRENT_DOCKER_VERSION),$(CURRENT_BOX_VERSION))
	@echo Nothing to do
else
	cd packer; packer build -var "docker_version=$(CURRENT_DOCKER_VERSION)" -var "debian_version=$(CURRENT_DEBIAN_VERSION)" -var "output_directory=/tmp" -only builder.virtualbox-iso.docker packer.pkr.hcl
endif

test:
	vagrant box add --name "testing-docker-box" $(OUTPUT_DIRECTORY)/packer-build/output/boxes/docker/$(CURRENT_DOCKER_VERSION)/virtualbox/docker.box
	mkdir -p $(OUTPUT_DIRECTORY)/vagrant-docker-test; cd $(OUTPUT_DIRECTORY)/vagrant-docker-test; vagrant init testing-docker-box; \
	vagrant up --provider virtualbox; \
	vagrant provision; \
	DOCKER_HOST="tcp://$(vagrant ssh-config | grep -i "HostName" | awk '{ print $2 }'):$(vagrant port --guest 2375)/" $(HOME)/.Yohnah/Docker/docker run hello-world; \
	vagrant destroy -f 

clean_test:
	vagrant box remove testing-docker-box || true
	rm -fr $(OUTPUT_DIRECTORY)/vagrant-docker-test

upload:
	cd Packer; packer build -var "input_directory=$(OUTPUT_DIRECTORY)" -var "version=$(NEW_VERSION)" -var "version_description=Build version: $(DATETIME)" upload-box-to-vagrant-cloud.pkr.hcl

clean: clean_test
	rm -fr $(OUTPUT_DIRECTORY)/packer-build
