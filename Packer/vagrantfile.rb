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
  end
  
  if OS.mac?
    HostDir = ENV["HOME"]
    GuestDir = HostDir
    Host_OS = "mac"
  end
  
  if OS.linux?
    HostDir = ENV["HOME"]
    GuestDir = HostDir
    Host_OS = "linux"
  end
  
  $msg = <<-MSG
  Welcome to Docker Linux box for Vagrant by Yohnah
  =================================================
  Host Operative System detected: #{Host_OS}
  Yohnah/Docker was successfully installed on your device
  The project repository is https://github.com/Yohnah-org/Docker for further information.
  MSG
  
  # Vagrant file definition
  
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
    end
  
    config.vm.provider "parallels" do |pl, override|
      pl.memory = 2048
      pl.cpus = 2
    end
  
    config.vm.provider "hyperv" do |hv, override|
      hv.memory = 2048
      hv.cpus = 2
    end
  
    config.vm.provider "vmware_desktop" do |vm, override|
      vm.memory = 2048
      vm.cpus = 2
    end
  
    $envvars = <<-EOF
    echo export HOST_OS=\"#{Host_OS}\" | sudo tee /etc/profile.d/envvars.sh
    EOF
  
    config.vm.provision "shell", inline: $envvars
  
    $setplugins = <<-EOF
    sed -i '/#VAGRANT-BEGIN/,/#VAGRANT-END/d' /vagrant/Vagrantfile
    echo " " >> /vagrant/Vagrantfile
    echo "#VAGRANT-BEGIN" >> /vagrant/Vagrantfile
    echo "# Added commands to vagrant cli to manage the kubernetes box. DO NOT MODIFY" >> /vagrant/Vagrantfile
    ls /usr/local/share/vagrant-plugins/*-vagrantfile-embedded-plugins.rb 2>/dev/null | while read FILE;
    do
        cat $FILE >> /vagrant/Vagrantfile
        echo "" >> /vagrant/Vagrantfile
        echo "" >> /vagrant/Vagrantfile
        
    done
    echo "#VAGRANT-END" >> /vagrant/Vagrantfile
    EOF
  
    config.vm.provision "shell", inline: $setplugins, run: "always"
  
    $updateso = <<-EOF
    sudo apt-get update
    sudo apt-get -y dist-upgrade
    EOF

    config.vm.provision "shell", inline: $updateso

  end