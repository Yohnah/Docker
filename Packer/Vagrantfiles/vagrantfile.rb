# -*- mode: ruby -*-
# vi: set ft=ruby :

module LocalCommand
  class Config < Vagrant.plugin("2", :config)
      attr_accessor :command
  end

  class Plugin < Vagrant.plugin("2")
      name "local_shell"

      config(:local_shell, :provisioner) do
          Config
      end

      provisioner(:local_shell) do
          Provisioner
      end
  end

  class Provisioner < Vagrant.plugin("2", :provisioner)
      def provision
          result = system "#{config.command}"
      end
  end
end

module OS
  def OS.windows?
      (/cygwin|mswin|mingw|bccwin|wince|emx/ =~ RUBY_PLATFORM) != nil
  end

  def OS.mac?
      (/darwin/ =~ RUBY_PLATFORM) != nil
  end

  def OS.unix?
      !OS.windows?
  end

  def OS.linux?
      OS.unix? and not OS.mac?
  end
end


Host_OS = "win"
if OS.windows?
  HostDir = ENV["USERPROFILE"]
  Aux = HostDir.split('\\')
  Aux.shift()
  GuestDir = "/" + Aux.join('/')
  Host_OS = "win"

  $install_docker_client = "cmd /c .\\installer\\docker-cli-installer.cmd"
  $uninstall_docker_client = "cmd /c .\\installer\\docker-cli-uninstaller.cmd"
end

if OS.mac?
  HostDir = ENV["HOME"]
  GuestDir = HostDir
  Host_OS = "mac"

  $install_docker_client = "sh ./installer/docker-cli-installer.sh"
  $uninstall_docker_client = "sh ./installer/docker-cli-uninstaller.sh"
end

if OS.linux?
  HostDir = ENV["HOME"]
  GuestDir = HostDir
  Host_OS = "linux"

  $install_docker_client = "sh ./installer/docker-cli-installer.sh"
  $uninstall_docker_client = "sh ./installer/docker-cli-uninstaller.sh"
end

$msg = <<MSG
Welcome to Docker Linux box for Vagrant by Yohnah

Host Operative System: #{Host_OS}

Yohnah/Docker was successfully installed on your device

Environment variables were updated in your user profile, but it is necessary reload terminal, thus, open a new terminal and close this one

Once refreshed the enviroment variables in your terminal, just run "docker" command

Further information, see: https://github.com/Yohnah/Docker

MSG

Vagrant.configure(2) do |config|
  config.vm.post_up_message = $msg
  config.ssh.shell = '/bin/sh'
  config.vm.hostname = "docker"

  config.vm.synced_folder HostDir, GuestDir

  config.vm.network "forwarded_port", guest: 2375, host: 2375, host_ip: "127.0.0.1", auto_correct: true

  config.vm.network "private_network", type: "dhcp"

  config.vm.provider "virtualbox" do |vb, override|
    vb.memory = 512
    vb.cpus = 2
    vb.customize ["modifyvm", :id, "--vram", "128"]
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
    vb.customize ["modifyvm", :id, "--audio", "none"]
    vb.customize ["modifyvm", :id, "--uart1", "off"] #Disconnect serial port to permit box up on windows/non-unixlike devices
    vb.customize ['modifyvm', :id, '--vrde', 'off']
    override.vm.provision "shell", inline: "/usr/bin/deploy-docker-files.sh #{Host_OS} virtualbox"
  end

  config.vm.provider "hyperv" do |vb, override|
    override.vm.provision "shell", inline: "/usr/bin/deploy-docker-files.sh #{Host_OS} hyperv"
  end

  config.vm.provider "parallels" do |vb, override|
    override.vm.provision "shell", inline: "/usr/bin/deploy-docker-files.sh #{Host_OS} parallels"
  end


  config.trigger.before :destroy do |trigger|
    trigger.name = "Uninstalling docker client"
    trigger.run = {inline: $uninstall_docker_client}
    trigger.run_remote = {inline: "rm -fr /vagrant/installer"}
  end

  config.trigger.after :up do |trigger|
    trigger.name = "Installing docker client"
    trigger.run = {inline: $install_docker_client}
  end

  #config.vm.provision "install-docker-cli", type: "local_shell", command: $install_docker_client
end