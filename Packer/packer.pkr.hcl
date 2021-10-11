variable "output_directory" {
    type = string
    default = "."
}

locals {
    box_name = "docker"
}

source "vagrant" "virtualbox" {
    communicator = "ssh"
    source_path = "Yohnah/Alpine"
    provider = "virtualbox"
    add_force = true
    box_name = local.box_name
    output_dir = "${var.output_directory}/packer-build/output/boxes/${local.box_name}/virtualbox/"
    skip_add = false
    output_vagrantfile = "${path.root}/Vagrantfiles/vagrantfile.rb"
}


build {
    name = "builder"
    sources = ["source.vagrant.virtualbox"]

    provisioner "file"{
        source = "${path.root}/Provision/Files/motd"
        destination = "/tmp/motd"
    }

    provisioner "shell" {
        scripts = [
            "${path.root}/Provision/system.sh",
            "${path.root}/Provision/docker.sh",
            "${path.root}/Provision/clean.sh"
        ]
    }

    post-processors {
            post-processor "vagrant-cloud" {
            box_tag = "Yohnah/Docker"
            version="20.10.9"
            version_description="Further information: https://docs.docker.com/engine/release-notes/"
        }
    }

}