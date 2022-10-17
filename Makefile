export CURRENT_BOX_VERSION := $(shell TYPE=current_box_version sh ./makefile-resources/get-versions.sh)
export CURRENT_DOCKER_VERSION := $(shell TYPE=current_docker_version sh ./makefile-resources/get-versions.sh)
export ALLDOCKERRELEASES := $(shell TYPE=all_docker_releases sh ./makefile-resources/get-versions.sh)
export PROVIDER := virtualbox
export BOX_NAME := Docker
export VAGRANT_CLOUD_REPOSITORY_BOX_NAME := Yohnah/$(BOX_NAME)
export CURRENT_VERSION := $(CURRENT_DOCKER_VERSION)

.PHONY: all versions requirements checkifbuild build add_box del_box upload clean

all: version build test

versions:
	@echo "========================="
	@echo Current Docker Version: $(CURRENT_DOCKER_VERSION)
	@echo Current Box Version: $(CURRENT_BOX_VERSION)
	@echo All Docker releases: $(ALLDOCKERRELEASES)
	@echo "========================="

requirements:
	git submodule init
	git submodule update --remote --merge

build: requirements
	sh ./makefile-resources/prepare-build.sh
	cd Debian; make build BOX_NAME=$(BOX_NAME) CURRENT_VERSION=$(CURRENT_DOCKER_VERSION) VAGRANT_CLOUD_REPOSITORY_BOX_NAME=$(VAGRANT_CLOUD_REPOSITORY_BOX_NAME) PROVIDER=$(PROVIDER)

add_box:
	cd Debian; make add_box BOX_NAME=$(BOX_NAME) CURRENT_VERSION=$(CURRENT_DOCKER_VERSION) VAGRANT_CLOUD_REPOSITORY_BOX_NAME=$(VAGRANT_CLOUD_REPOSITORY_BOX_NAME) PROVIDER=$(PROVIDER)

del_box:
	cd Debian; make del_box BOX_NAME=$(BOX_NAME) CURRENT_VERSION=$(CURRENT_DOCKER_VERSION) VAGRANT_CLOUD_REPOSITORY_BOX_NAME=$(VAGRANT_CLOUD_REPOSITORY_BOX_NAME) PROVIDER=$(PROVIDER)

upload:
	cd Debian/; make upload BOX_NAME=$(BOX_NAME) CURRENT_VERSION=$(CURRENT_DOCKER_VERSION) VAGRANT_CLOUD_REPOSITORY_BOX_NAME=$(VAGRANT_CLOUD_REPOSITORY_BOX_NAME) PROVIDER=$(PROVIDER)

clean: 
	rm -fr Debian/
	git submodule init
	git submodule update --remote --merge
	cd Debian/; make clean BOX_NAME=$(BOX_NAME) CURRENT_VERSION=$(CURRENT_DOCKER_VERSION) VAGRANT_CLOUD_REPOSITORY_BOX_NAME=$(VAGRANT_CLOUD_REPOSITORY_BOX_NAME) PROVIDER=$(PROVIDER)