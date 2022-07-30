CURRENT_BOX_VERSION := $(subst ", ,$(shell curl -sS "https://app.vagrantup.com/api/v1/box/Yohnah/Docker" | jq '.current_version.version'))
CURRENT_DOCKER_VERSION := $(shell curl -s https://docs.docker.com/engine/release-notes/ | grep -i "nomunge" | grep -v "Version" | grep -v "<ul>" | head -n 1 | sed -e 's/<[^>]*>//g' | sed 's/ //g')
CURRENT_DEBIAN_VERSION := $(shell curl -s https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/ | grep -oE "debian-(.*)-amd64-netinst.iso" | sed -e 's/<[^>]*>//g' | cut -d">" -f 1 | sed 's/"//g' | head -n 1 | cut -d- -f2)
OUTPUT_DIRECTORY := /tmp
DATETIME := $(shell date "+%Y-%m-%d %H:%M:%S")
PROVIDER := virtualbox
MANIFESTFILE := $(OUTPUT_DIRECTORY)/packer-build/$(CURRENT_DOCKER_VERSION)/$(PROVIDER)/manifest.json

.PHONY: all version requirements build load_box destroy_box test clean_test upload clean getDockerVersions deleteVersion

all: version build test

getDockerVersions:
	@echo ::set-output name=versions::$(shell (curl -s https://docs.docker.com/engine/release-notes/ | grep -i 'nomunge' | grep -v 'Version' | grep -v '<ul>' | sed -e 's/<[^>]*>//g' | sed 's/ //g' | jq -ncR '[inputs]' | sed 's/"/\\"/g'))
	@echo ::set-output name=debianversion::$(CURRENT_DEBIAN_VERSION)

deleteVersion:
	vagrant cloud provider delete -f Yohnah/Docker $(PROVIDER) $(VERSION) || true

version: 
	@echo "========================="
	@echo Current Docker Version: $(CURRENT_DOCKER_VERSION)
	@echo Current Box Version: $(CURRENT_BOX_VERSION)
	@echo Current Debian Version: $(CURRENT_DEBIAN_VERSION)
	@echo Provider: $(PROVIDER)
	@echo "========================="
	@echo ""
	@echo ::set-output name=dockerversion::$(CURRENT_DOCKER_VERSION)
	@echo ::set-output name=debianversion::$(CURRENT_DEBIAN_VERSION)
	@echo ""
ifeq ($(shell echo "$(CURRENT_DOCKER_VERSION)" | sed 's/ //g'),$(shell echo "$(CURRENT_BOX_VERSION)" | sed 's/ //g'))
	@echo Not a new docker version exists, so, build cannot be launched
	exit 1
else
	@echo New docker versions exists, build job can be launched
	exit 0
endif

build:
	mkdir -p $(OUTPUT_DIRECTORY)/packer-build/$(CURRENT_DOCKER_VERSION)
	cd packer; packer build -var "docker_version=$(CURRENT_DOCKER_VERSION)" -var "debian_version=$(CURRENT_DEBIAN_VERSION)" -var "output_directory=/tmp" -only builder.$(PROVIDER)-iso.docker packer.pkr.hcl
	@echo ::set-output name=manifestfile::$(MANIFESTFILE)

test:
	vagrant box add --provider $(PROVIDER) -f --name "testing-docker-box" $(shell cat $(MANIFESTFILE) | jq ".builds | .[].files | .[].name")
	mkdir -p $(OUTPUT_DIRECTORY)/$(CURRENT_DOCKER_VERSION)/vagrant-docker-test; cd $(OUTPUT_DIRECTORY)/$(CURRENT_DOCKER_VERSION)/vagrant-docker-test; vagrant init testing-docker-box; \
	vagrant up --provider $(PROVIDER); \
	vagrant provision; \
	DOCKER_HOST="tcp://$(vagrant ssh-config | grep -i "HostName" | awk '{ print $2 }'):$(vagrant port --guest 2375)/" $(HOME)/.Yohnah/Docker/docker run hello-world; \
	vagrant destroy -f 

load_box:
	vagrant box add --provider $(PROVIDER) -f --name "testing-docker-box" $(shell cat $(MANIFESTFILE) | jq '.builds | .[].files | .[].name')
	mkdir -p $(OUTPUT_DIRECTORY)/$(OUTPUT_DIRECTORY)/vagrant-docker-test; cd $(OUTPUT_DIRECTORY)/$(CURRENT_DOCKER_VERSION)/vagrant-docker-test; vagrant init testing-docker-box; \
	vagrant up --provider $(PROVIDER); \
	vagrant ssh

destroy_box:
	cd $(OUTPUT_DIRECTORY)/$(CURRENT_DOCKER_VERSION)/vagrant-docker-test; vagrant destroy -f

clean_test:
	vagrant box remove -f --provider $(PROVIDER) testing-docker-box || true
	rm -fr $(OUTPUT_DIRECTORY)/$(CURRENT_DOCKER_VERSION)/vagrant-docker-test || true

upload:
	vagrant cloud box create --no-private Yohnah/Docker || true
	cd Packer; packer build -var "box-to-upload=$(shell cat $(MANIFESTFILE) | jq '.builds | .[].files | .[].name')" -var "docker_version=$(CURRENT_DOCKER_VERSION)" -var "debian_version=$(CURRENT_DEBIAN_VERSION)" -var "builtDateTime=$(DATETIME)" -var "provider=$(PROVIDER)" upload-box-to-vagrant-cloud.pkr.hcl

clean: clean_test
	rm -fr $(OUTPUT_DIRECTORY)/packer-build || true
