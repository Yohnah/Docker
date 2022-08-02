export CURRENT_BOX_VERSION := $(shell TYPE=current_box_version sh ./makefile-resources/get-versions.sh)
export CURRENT_DOCKER_VERSION := $(shell TYPE=current_docker_version sh ./makefile-resources/get-versions.sh)
export CURRENT_DEBIAN_VERSION := $(shell TYPE=current_debian_version sh ./makefile-resources/get-versions.sh)
export ALLDOCKERRELEASES := $(shell TYPE=all_docker_releases sh ./makefile-resources/get-versions.sh)
export OUTPUT_DIRECTORY := /tmp
export PACKER_DIRECTORY_OUTPUT := $(OUTPUT_DIRECTORY)/packer-build
export DATETIME := $(shell date "+%Y-%m-%d %H:%M:%S")
export PROVIDER := virtualbox
export MANIFESTFILE := $(PACKER_DIRECTORY_OUTPUT)/$(CURRENT_DOCKER_VERSION)/manifest.json
export UPLOADER_DIRECTORY := $(PACKER_DIRECTORY_OUTPUT)/toupload

.PHONY: all versions checkifbuild requirements build test uploader clean done

all: versions build test done

versions:
	@echo "========================="
	@echo Current Docker Version: $(CURRENT_DOCKER_VERSION)
	@echo Current Box Version: $(CURRENT_BOX_VERSION)
	@echo Current Debian Version: $(CURRENT_DEBIAN_VERSION)
	@echo All Docker releases: $(ALLDOCKERRELEASES)
	@echo "========================="
	@echo ::set-output name=dockerversion::$(CURRENT_DOCKER_VERSION)
	@echo ::set-output name=debianversion::$(CURRENT_DEBIAN_VERSION)
	@echo ::set-output name=boxversion::$(CURRENT_BOX_VERSION)
	@echo ::set-output name=alldockerreleases::$(ALLDOCKERRELEASES)

checkifbuild:
	@echo "========================="
	@echo New docker box must be built: $(shell CURRENT_DOCKER_VERSION=$(CURRENT_DOCKER_VERSION) CURRENT_BOX_VERSION=$(CURRENT_BOX_VERSION) TYPE=checkifbuild sh ./makefile-resources/get-versions.sh)
	@echo "========================="
	@echo ::set-output name=verdict::$(shell CURRENT_DOCKER_VERSION=$(CURRENT_DOCKER_VERSION) CURRENT_BOX_VERSION=$(CURRENT_BOX_VERSION) TYPE=checkifbuild sh ./makefile-resources/get-versions.sh)


requirements:
	mkdir -p $(PACKER_DIRECTORY_OUTPUT)/$(CURRENT_DOCKER_VERSION)/$(PROVIDER)
	mkdir -p $(PACKER_DIRECTORY_OUTPUT)/toupload
	mkdir -p $(PACKER_DIRECTORY_OUTPUT)/test/$(CURRENT_DOCKER_VERSION)/$(PROVIDER)

build: requirements
	sh ./makefile-resources/build-docker-box.sh
	@echo ::set-output name=manifestfile::$(MANIFESTFILE)

test: requirements
	sh ./makefile-resources/test-created-box.sh
	

done:
	touch $(PACKER_DIRECTORY_OUTPUT)/toupload/done

upload:
	sh ./makefile-resources/upload-docker-box.sh

remove_box:
	sh ./makefile-resources/remove-box.sh

clean: 
	rm -fr $(PACKER_DIRECTORY_OUTPUT) || true
