# -*- mode: ruby -*-
# vi: set ft=ruby :

$msg = <<MSG
Welcome to Docker Linux box for Vagrant by Yohnah

MSG

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

if OS.windows?
  HostDir = ENV["USERPROFILE"]
  Aux = HostDir.split('\\')
  Aux.shift()
  GuestDir = "/" + Aux.join('/')
end

if OS.mac?
  HostDir = ENV["HOME"]
  GuestDir = HostDir
end

if OS.linux?
  HostDir = ENV["HOME"]
  GuestDir = HostDir
end

Vagrant.configure(2) do |config|
  config.vm.post_up_message = $msg
  config.ssh.shell = '/bin/ash'
  config.vm.hostname = "docker"

  config.vm.synced_folder HostDir, GuestDir

  config.vm.network "forwarded_port", guest: 2375, host: 2375, host_ip: "127.0.0.1", auto_correct: true

  config.vm.network "private_network", type: "dhcp"

  config.vm.provider "virtualbox" do |vb, override|
    vb.memory = 2048
    vb.cpus = 2
    vb.customize ["modifyvm", :id, "--vram", "128"]
    vb.customize ["modifyvm", :id, "--graphicscontroller", "vmsvga"]
    vb.customize ["modifyvm", :id, "--audio", "none"]
    vb.customize ["modifyvm", :id, "--uart1", "off"] #Disconnect serial port to permit box up on windows/non-unixlike devices
    vb.customize ['modifyvm', :id, '--vrde', 'off']
  end

end