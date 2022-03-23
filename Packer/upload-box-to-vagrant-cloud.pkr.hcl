variable "input_directory" {
    type = string
}

variable "version" {
    type = string
}

variable "version_description"{
  type = string
}

variable "provider"{
  type = string
}

locals {
    vm_name = "docker"
    box_files = [
            "${var.input_directory}/packer-build/output/boxes/${local.vm_name}/${var.version}/${var.provider}/docker.box"
    ]
}

source "null" "docker" {
  communicator = "none"
}

build {
  sources = ["source.null.docker"]

  post-processors {
    post-processor "artifice" {
      files = local.box_files
    }
    post-processor "vagrant-cloud" {
      box_tag      = "Yohnah/Docker"
      keep_input_artifact = false
      version      = var.version
      version_description = "Built at ${var.version_description}"
    }
  }
}
