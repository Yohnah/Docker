variable "box-to-upload" {
  type = string
}

variable "docker_version" {
  type = string
}

variable "debian_version" {
  type = string
}

variable "builtDateTime"{
  type = string
}

variable "provider"{
  type = string
}

source "null" "upload" {
  communicator = "none"
}

build {
  sources = ["source.null.upload"]

  post-processors {
    post-processor "artifice" {
      files = [var.box-to-upload]
    }
    post-processor "vagrant-cloud" {
      box_tag = "Yohnah/Docker"
      keep_input_artifact = false
      version = var.docker_version
      version_description = <<EOF
        Built at ${var.builtDateTime}
        Debian version: ${var.debian_version}
      EOF
    }
  }
}