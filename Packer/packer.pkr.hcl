variable "output_directory" {
    type = string
}

variable "version" {
    type = string
}

locals {
    box_name = "docker"
}

source "vagrant" "virtualbox" {
    communicator = "ssh"
    source_path = "Yohnah/Debian"
    provider = "virtualbox"
    add_force = false
    box_name = local.box_name
    output_dir = "${var.output_directory}/packer-build/output/boxes/${local.box_name}/${var.version}/virtualbox/"
    skip_add = false
    output_vagrantfile = "${path.root}/Vagrantfiles/vagrantfile.rb"
}

source "vagrant" "parallels" {
    communicator = "ssh"
    source_path = "Yohnah/Debian"
    provider = "parallels"
    add_force = false
    box_name = local.box_name
    output_dir = "${var.output_directory}/packer-build/output/boxes/${local.box_name}/${var.version}/parallels/"
    skip_add = false
    output_vagrantfile = "${path.root}/Vagrantfiles/vagrantfile.rb"
}

source "vagrant" "hyperv" {
    communicator = "ssh"
    source_path = "Yohnah/Debian"
    provider = "hyperv"
    add_force = false
    box_name = local.box_name
    output_dir = "${var.output_directory}/packer-build/output/boxes/${local.box_name}/${var.version}/hyperv/"
    skip_add = false
    output_vagrantfile = "${path.root}/Vagrantfiles/vagrantfile.rb"
}

build {
    name = "builder"
    sources = [
        "source.vagrant.virtualbox",
        "source.vagrant.parallels",
        "source.vagrant.hyperv"
    ]

    provisioner "file"{
        source = "${path.root}/Provision/Files/motd"
        destination = "/tmp/motd"
    }

    provisioner "file"{
        source = "${path.root}/Provision/Files/get-ips.sh"
        destination = "/tmp/get-ips.sh"
    }

    provisioner "file"{
        source = "${path.root}/Provision/Files/docker-cli-installer.cmd"
        destination = "/tmp/docker-cli-installer.cmd"
    }

    provisioner "file"{
        source = "${path.root}/Provision/Files/docker-cli-uninstaller.cmd"
        destination = "/tmp/docker-cli-uninstaller.cmd"
    }

    provisioner "file"{
        source = "${path.root}/Provision/Files/docker-cli-installer.sh"
        destination = "/tmp/docker-cli-installer.sh"
    }

    provisioner "file"{
        source = "${path.root}/Provision/Files/docker-cli-uninstaller.sh"
        destination = "/tmp/docker-cli-uninstaller.sh"
    }

    provisioner "file"{
        source = "${path.root}/Provision/Files/deploy-docker-files.sh"
        destination = "/tmp/deploy-docker-files.sh"
    }


    provisioner "shell" {
        environment_vars = [
            "VERSION=${var.version}"
       ]
        scripts = [
            "${path.root}/Provision/system.sh",
            "${path.root}/Provision/docker.sh",
            "${path.root}/Provision/clean.sh"
        ]
    }

    post-processors {
            post-processor "vagrant-cloud" {
            box_tag = "Yohnah/Docker"
            version=var.version
            version_description="Further information: https://docs.docker.com/engine/release-notes/"
        }
    }

}