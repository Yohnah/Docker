variable "input_directory" {
    type = string
}

variable "version" {
    type = string
}

variable "providers" {
    type = list(string)
    default = ["virtualbox","parallels","hyperv","vmware_desktop"]
}


locals {
    vm_name = "docker"
    box_files = [
        for pv in var.providers: 
            "${var.input_directory}/packer-build/output/boxes/${local.vm_name}/${var.version}/${pv}/docker.box"
    ]
}

source "null" "uploading" {
  communicator = "none"
}

build {
  sources = ["source.null.dummy"]

  post-processors {
    post-processor "artifice" {
      files = local.box_files
    }
    post-processor "vagrant-cloud" {
      box_tag      = "Yohnah/Docker"
      version      = var.version
    }
  }
}
