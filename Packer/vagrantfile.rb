# -*- mode: ruby -*-
# vi: set ft=ruby :

class VagrantPlugins::ProviderVirtualBox::Action::Network
  def dhcp_server_matches_config?(dhcp_server, config)
    true
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
=================================================

Host Operative System detected: #{Host_OS}
Yohnah/Docker was successfully installed on your device

Further information, see: https://github.com/Yohnah/Docker

Reload your terminal to refresh the environment variables

Run the following command to list the assigned IP addresses:

  vagrant ssh -- get-ips.sh

MSG

Vagrant.configure(2) do |config|
  config.vm.post_up_message = $msg
  config.ssh.shell = '/bin/sh'

  config.vm.synced_folder HostDir, GuestDir
  
  config.vm.network "forwarded_port", guest: 2375, host: 2375, host_ip: "127.0.0.1", auto_correct: true

  config.vm.provider "virtualbox" do |vb, override|
    vb.memory = 2048
    vb.cpus = 2
    vb.customize ["modifyvm", :id, "--vram", "128"]
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
    vb.customize ["modifyvm", :id, "--audio", "none"]
    vb.customize ["modifyvm", :id, "--uart1", "off"]
    vb.customize ['modifyvm', :id, '--vrde', 'off']
    override.vm.network "private_network", type: "dhcp"
    override.vm.provision "shell",
      env: {"OSType" => Host_OS,"HyperVisor" => "virtualbox"}, 
      inline: "bash /usr/bin/deploy-docker-files.sh"
  end

  config.vm.provider "parallels" do |pl, override|
    pl.memory = 2048
    pl.cpus = 2
    override.vm.network "private_network", type: "dhcp"
    override.vm.provision "shell",
      env: {"OSType" => Host_OS,"HyperVisor" => "parallels"}, 
      inline: "bash /usr/bin/deploy-docker-files.sh"
  end

  config.vm.provider "hyperv" do |hv, override|
    hv.memory = 2048
    hv.cpus = 2
    override.vm.provision "shell",
      env: {"OSType" => Host_OS,"HyperVisor" => "hyperv"}, 
      inline: "bash /usr/bin/deploy-docker-files.sh"
  end

  config.vm.provider "vmware_desktop" do |vm, override|
    vm.memory = 2048
    vm.cpus = 2
    override.vm.provision "shell",
      env: {"OSType" => Host_OS,"HyperVisor" => "vmware_desktop"}, 
      inline: "bash /usr/bin/deploy-docker-files.sh"
  end

  if ENV['INSTALL_DOCKER_CLIENT'].to_s.downcase != "no"
    config.trigger.after :up, :provision do |install|
      install.name = "Installing docker client"
      install.info = "Running docker-cli installer"
      install.run = {inline: $install_docker_client}
    end
  end

  if ENV['INSTALL_DOCKER_CLIENT'].to_s.downcase != "no"
    config.trigger.before :destroy do |uninstall|
      uninstall.name = "Uninstalling docker client"
      uninstall.info = "Running docker-cli uninstaller"
      uninstall.run = {inline: $uninstall_docker_client}
      uninstall.run_remote = {inline: "rm -fr /vagrant/installer"}
    end
  end

end
