variable "output_directory" {
    type = string
}

variable "docker_version" {
    type = string
}

variable "debian_version" {
    type = string
}

locals {
    vm_name = "docker"
    debian_version = var.debian_version
    docker_version = var.docker_version
    http_directory = "${path.root}/http"
    iso_url = "https://cdimage.debian.org/debian-cd/current/amd64/iso-cd/debian-${local.debian_version}-amd64-netinst.iso"
    iso_checksum = "file:https://cdimage.debian.org/debian-cd/${local.debian_version}/amd64/iso-cd/SHA256SUMS"
    shutdown_command = "echo 'vagrant' | sudo -S shutdown -P now"
    boot_command = [
        "<esc><wait10s>",
        "install <wait>",
        "preseed/url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg <wait>",
        "debian-installer=en_US.UTF-8 <wait>",
        "auto <wait>",
        "locale=en_US.UTF-8 <wait>",
        "kbd-chooser/method=us <wait>",
        "keyboard-configuration/xkb-keymap=us <wait>",
        "netcfg/get_hostname={{ .Name }} <wait>",
        "netcfg/get_domain=vagrantup.com <wait>",
        "fb=false <wait>",
        "debconf/frontend=noninteractive <wait>",
        "console-setup/ask_detect=false <wait>",
        "console-keymaps-at/keymap=us <wait>",
        "grub-installer/bootdev=/dev/sda <wait>",
        "<enter><wait>"    
    ]
}

source "virtualbox-iso" "docker" {
    boot_command = local.boot_command
    boot_wait = "6s"
    cpus = 2
    memory = 1024
    disk_size = 10240
    guest_additions_path = "VBoxGuestAdditions_{{.Version}}.iso"
    guest_additions_url = ""
    guest_os_type = "docker_64"
    hard_drive_interface = "sata"
    headless = false
    http_content = {
         "/preseed.cfg" = templatefile("${path.root}/http/preseed.cfg.pkrtpl", {})
    }
    iso_checksum = local.iso_checksum
    iso_url = local.iso_url
    output_directory = "${var.output_directory}/packer-build/output/artifacts/${local.vm_name}/${var.docker_version}/virtualbox/"
    shutdown_command = local.shutdown_command
    ssh_password = "vagrant"
    ssh_port = 22
    ssh_timeout = "10000s"
    ssh_username = "vagrant"
    virtualbox_version_file = ".vbox_version"
    vm_name = "${local.vm_name}"
    vboxmanage = [
        ["modifyvm", "{{.Name}}", "--vram", "128"],
        ["modifyvm", "{{.Name}}", "--graphicscontroller", "vmsvga"],
        ["modifyvm", "{{.Name}}", "--vrde", "off"],
        ["modifyvm", "{{.Name}}", "--rtcuseutc", "on"]
    ]
}

source "parallels-iso" "docker" {
    boot_command = local.boot_command
    boot_wait = "6s"
    cpus = 2
    memory = 1024
    disk_size = 10240
    guest_os_type = "debian"
    http_content = {
         "/preseed.cfg" = templatefile("${path.root}/http/preseed.cfg.pkrtpl", {})
    }
    iso_checksum = local.iso_checksum
    iso_url = local.iso_url
    output_directory = "${var.output_directory}/packer-build/output/artifacts/${local.vm_name}/${var.version}/parallels/"
    shutdown_command = local.shutdown_command
    parallels_tools_flavor = "lin"
    ssh_password = "vagrant"
    ssh_port = 22
    ssh_timeout = "10000s"
    ssh_username = "vagrant"
    prlctl_version_file = ".prlctl_version"
    vm_name = "${local.vm_name}"
}

source "vmware-iso" "docker" {
    boot_command = local.boot_command
    boot_wait = "6s"
    cpus = 2
    memory = 1024
    disk_size = 10240
    guest_os_type = "debian8-64"
    headless = false
    http_content = {
         "/preseed.cfg" = templatefile("${path.root}/http/preseed.cfg.pkrtpl", {})
    }
    iso_checksum = local.iso_checksum
    iso_url = local.iso_url
    output_directory = "${var.output_directory}/packer-build/output/artifacts/${local.vm_name}/${var.version}/vmware/"
    shutdown_command = local.shutdown_command
    ssh_password = "vagrant"
    ssh_port = 22
    ssh_timeout = "10000s"
    ssh_username = "vagrant"
    tools_upload_flavor = "linux"
    vm_name = "${local.vm_name}"
    vmx_data = {
        "cpuid.coresPerSocket": "1",
        "ethernet0.pciSlotNumber": "32"
      }
    vmx_remove_ethernet_interfaces = true
}

source "hyperv-iso" "docker" {
    boot_command = local.boot_command
    boot_wait = "6s"
    cpus = 2
    memory = 1024
    disk_size = 10240
    generation = 1
    headless = false
    http_content = {
         "/preseed.cfg" = templatefile("${path.root}/http/preseed.cfg.pkrtpl", {})
    }
    iso_checksum = local.iso_checksum
    iso_url = local.iso_url
    output_directory = "${var.output_directory}/packer-build/output/artifacts/${local.vm_name}/${var.version}/hyperv/"
    shutdown_command = local.shutdown_command
    ssh_password = "vagrant"
    ssh_port = 22
    ssh_timeout = "10000s"
    ssh_username = "vagrant"
    switch_name = "Default Switch"
    enable_virtualization_extensions = false
    enable_mac_spoofing = false
    vm_name = "${local.vm_name}"
}

build {
    name = "builder"

    sources = [
        "source.virtualbox-iso.docker",
        "source.parallels-iso.docker",
        "source.vmware-iso.docker",
        "source.hyperv-iso.docker"

    ]

    provisioner "shell" {
        environment_vars  = ["HOME_DIR=/home/vagrant"]
        execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
        expect_disconnect = true
        scripts = [
            "${path.root}/setup-os-scripts/update.sh",
            "${path.root}/setup-os-scripts/sshd.sh",
            "${path.root}/setup-os-scripts/networking.sh",
            "${path.root}/setup-os-scripts/sudoers.sh",
            "${path.root}/setup-os-scripts/vagrant-conf.sh",
            "${path.root}/setup-os-scripts/systemd.sh"
        ] 
    }

    provisioner "shell" {
        only = ["virtualbox-iso.docker"]
        environment_vars  = ["HOME_DIR=/home/vagrant"]
        execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
        expect_disconnect = true
        scripts = [
            "${path.root}/setup-os-scripts/virtualbox.sh"
        ] 
    }

    provisioner "shell" {
        only = ["parallels-iso.docker"]
        environment_vars  = ["HOME_DIR=/home/vagrant"]
        execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
        expect_disconnect = true
        scripts = [
            "${path.root}/setup-os-scripts/parallels.sh"
        ] 
    }

    provisioner "shell" {
        only = ["vmware-iso.docker"]
        environment_vars  = ["HOME_DIR=/home/vagrant"]
        execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
        expect_disconnect = true
        scripts = [
            "${path.root}/setup-os-scripts/vmware.sh"
        ] 
    }

    provisioner "file" {
        source      = "${path.root}/files-to-upload/"
        destination = "/tmp/"
    }

    provisioner "shell" {
        environment_vars = [
            "VERSION=${local.docker_version}"
        ]
        scripts = [
            "${path.root}/provision-scripts/system-os.sh",
            "${path.root}/provision-scripts/docker.sh"
        ]
    }

    provisioner "shell" {
        environment_vars  = ["HOME_DIR=/home/vagrant"]
        execute_command   = "echo 'vagrant' | {{ .Vars }} sudo -S -E sh -eux '{{ .Path }}'"
        expect_disconnect = true
        scripts = [
            "${path.root}/setup-os-scripts/cleanup.sh",
            "${path.root}/setup-os-scripts/minimize.sh"
        ] 
    }

    post-processors {
        post-processor "vagrant" {
          keep_input_artifact = false
          output = "${var.output_directory}/packer-build/output/boxes/${local.vm_name}/${var.docker_version}/{{.Provider}}/{{.BuildName}}.box"
          vagrantfile_template = "${path.root}/vagrantfile.rb"
        }
        post-processor "manifest" {
            output = "${var.output_directory}/packer-build/${var.docker_version}/manifest.json"
        }
    }

}