___
***Notice:***
Everything is working again. The boxes are available again on Vagrant Cloud, thanks for your patience.

The mayor version was raised it up because of refactoring all code.
___

# Begin

Welcome to this modest project, a Docker Desktop alternative on Vagrant by Hashicorp

Just run ***vagrant up*** command and get a worked Docker Desktop alterative

Debian GNU/Linux is used as OS based system for compatibily reasons among the listed hypervisors below
___
***Note:***
Vagrant Cloud repository: [https://app.vagrantup.com/Yohnah/boxes/Docker](https://app.vagrantup.com/Yohnah/boxes/Docker)
___

- [Begin](#begin)
- [Requirements](#requirements)
  - [Compatible Operative System on host](#compatible-operative-system-on-host)
  - [Software](#software)
  - [Hypervisor](#hypervisor)
- [Issues](#issues)
- [How to use](#how-to-use)
  - [Short prompts](#short-prompts)
  - [Long prompts](#long-prompts)
- [Alternative use of docker on Yohnah/Docker box](#alternative-use-of-docker-on-yohnahdocker-box)
- [Port forwarding access](#port-forwarding-access)
- [Keep in mind](#keep-in-mind)
  - [Running on MacOS](#running-on-macos)
  - [Running on VirtualBox](#running-on-virtualbox)
  - [Running on HyperV](#running-on-hyperv)
  - [Running on VMWare_Desktop](#running-on-vmware_desktop)
- [Building from sources](#building-from-sources)

# Requirements

## Compatible Operative System on host

* Windows 10/11
* MacOS (tested on BigSur x86_64 arch)
* GNU/Linux

## Software

* Vagrant: <https://www.vagrantup.com/>

## Hypervisor

One of the following hypervisors must be installed:

* Virtualbox: <https://www.virtualbox.org/>
* Parallels: <https://www.parallels.com/> (only x86_64 compatible)
* Hyper-V: <https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/about/>
* VMWare Workstation or Fusion: <https://www.vmware.com/>

# Issues

If you get an issue or problem running Yohnah/Docker, please, kindly open a issue into [issues section](https://github.com/Yohnah/Docker/issues) into GitHub portal. Please, be as detailed as possible 

# How to use

## Short prompts

Run on Unix-Like and MacOs:

~~~
$ vagrant init Yohnah/Docker
$ vagrant up #or vagrant up --provider <hypervisor>
$ docker --help
~~~

On Windows PowerShell:

~~~
PS C:\Users\JohnDoe> vagrant.exe init Yohnah/Docker
PS C:\Users\JohnDoe> vagrant.exe up #or vagrant up --provider <hypervisor>
PS C:\Users\JohnDoe> docker.exe --help
~~~

On Windows CMD:

~~~
C:\Users\JohnDoe> vagrant.exe init Yohnah/Docker
C:\Users\JohnDoe> vagrant.exe up #or vagrant up --provider <hypervisor>
C:\Users\JohnDoe> docker.exe --help
~~~

Resulting a configured and working docker service and installed client binaries on host device to be used just like Docker Desktop does

___
***Note:***
See Docker docs for futher information about Docker client binaries: https://docs.docker.com/engine/install/binaries/
___

***LOOK OUT!!!***
Sometimes docker clients binaries are not installed for any reason, when vagrant up command is run, vagrant does not fire the trigger to install the binaries, essentially when the boxes have to be downloaded a first time

If that happens, just run the provision command to force the docker client binaries installation:

~~~
$ vagrant provision
~~~
___

## Long prompts
___
***Note:*** The Unix and Unix-like commands shown below are the same for Windows OS, but knowing the commands ends with a .exe suffix (ex: docker.exe or vagrant.exe)
___

The Yohnah/Docker vagrant box was developed to be a Docker Desktop alternative, but adding the portability feature of Vagrant environment systems

Once the requirements are installed, in order to get Yohnah/Docker running on your system or device, the following command must be run within a directory on your host:

~~~
$ vagrant init Yohnah/Docker
~~~

This command set a vagrant workspace in the directory where it was run.

Next step the following command:

~~~
$ vagrant up
~~~

or alternative:

~~~
$ vagrant up --provider <hypervisor>
~~~

Which \<hypervisor\> should be one of supported ones listed in requirements section. This last command will perform the following steps:

1. Detect if the box was already downloaded, else, will download it from [Vagrant Cloud](https://app.vagrantup.com/Yohnah/boxes/Docker)
2. Raise the virtual machine up, using the default hypervisor configured on host, or using the hypervisor set by the --provider tag

___
***Note:***
For further information about how Vagrant works, please visit https://www.vagrantup.com/docs
___

However, the Yohnah/Docker box include artifacts to install the docker client binaries into your host considering host OS, be it Windows, Mac or Linux

After vagrant up is run, the box will trigger local actions onto the host to install and setup the docker client binaries, such as:

1. Setup the PATH environment variable
2. Copy all docker client binaries (same version as docker daemon installed into virtual machine) into your host machine
3. Setup the DOCKER_HOST environment variable
___
***Note:***
If a ***vagrant destroy*** command is run, the box will also trigger a reset to revert the actions listed above.
___

So, just run a ***vagrant up*** command in a Yohnah/Docker vagrant workspace and just run the docker client directly in your favourite terminal (reload your terminal to refresh environment variables before running docker client)
___
***LOOK OUT!!!***
Sometimes docker clients binaries are not installed for any reason, when vagrant up command is run, vagrant does not fire the trigger to install the binaries, essentially when the boxes have to be downloaded a first time

If that happens, just run the provision command to force the docker client binaries installation:

~~~
$ vagrant provision
~~~
___


# Alternative use of docker on Yohnah/Docker box

As alternative, docker can be used by ssh the box as follows, after the vagrant up was run:

~~~
$ vagrant ssh #in the vagrant folder workspace
~~~

In this manner, the docker client binaries is not neccessary to use

___
***Note:*** Set the INSTALL_DOCKER_CLIENT="NO" environment variable before running the ***vagrant up*** command to avoid installing the docker client binaries onto host device. 
___

# Port forwarding access


# Keep in mind

## Running on MacOS

The Yohnah/Docker box was built and test on MacOS Big Sur compatible with Vagrant. In spite of it, it should run on any x86/amd64 MacOS and not on new chips M1 Apple Silicon.

The main reason about it, I had no the opportunity to get and M1 Apple Silicon to build the packer instructions for M1 chip. So, when I may get one, I'll alter the packer code to support M1. It requires to using an GNU/Linux SO with ARM arch support.

Probably, the adaptation to M1 chip, will be performed on Parallels as hypervisor and not on VirtualBox. VirtualBox has no support for M1 chip yet at the time of writting this.

## Running on VirtualBox

VirtualBox is supported for most kind of operative systems in the market. Virtuanbox run on Windows, MacOs and GNU/Linux (always x86_64), hence, you can use Yohnah/Docker on any Host OS supported by Virtualbox

## Running on HyperV

Yohnah/Box runs fine on Windows machines using the HyperV hypervisor. However, it is important to know that Vagrant requires privileges to mount synced_folder (see [Vagrant docs](https://www.vagrantup.com/docs/providers/hyperv/usage) for more information)

Be sure that your windows user account, in order for running the ***vagrant up*** command, has enough privileges to mount directories by SMB/CIFS protocol

___
***Note:*** It is very important to get the /vagrant directory mounted within the box when HyperV. The docker client binaries installation and setup only work if /vagrant directory is mounted. Otherwise, the docker client can only be used by ssh the guest machine.
___

There are many limitations when Vagrant is running on Hyper-V. For futher information visit <https://www.vagrantup.com/docs/providers/hyperv/limitations>

One of those limitations is that Vagrant cannot create private networks to obtain an additional IP address. So if you need to access the service published by a running docker container, you will have to use the same IP address as the one used by vagrant ssh. Be aware of port conflicts with DOCKER_HOST running port

## Running on VMWare_Desktop

VMWare fusion was used to create and test the vagrant box, hence, if you detect any trouble using it on WMWare workstation or others, please, kindly report it into [issues section](https://github.com/Yohnah/Docker/issues)

There are several known issues when Vagrant is running using vmware_desktop provider. Please, visit <https://www.vagrantup.com/docs/providers/vmware/known-issues> for futher information.

One of those issues is a lossing DNS connection when a private network is created. So if you need to access the service published by a running docker container, you will have to use the same IP address as the one used by vagrant ssh. Be aware of port conflicts with DOCKER_HOST running port

# Building from sources

Another option to use Yohnah/Box is building it from sources.

To reach it out, first of all, the code must be cloned from the git repository on GitHub:

~~~
$ git clone github.com/Yohnah/Docker.git
~~~

And, inside of git workspace run the following command:

~~~
docker/$ packer build -var "output_directory=<path to base directory>" -var version="<Docker engine version>" Packer/packer.pkr.hcl
~~~
___
***Note:*** Comment all lines into packer code about ***vagrant-cloud*** post-processors if you don't want to upload the resulting box to vagrant cloud repository or set the VAGRANT_CLOUD_TOKEN with a vagrant cloud token instead (see [Packer docs about Vagrant Cloud post-processors](https://www.packer.io/docs/post-processors/vagrant/vagrant-cloud) for further information). On the contrary, you will get an error exception on run the command
___

Which ***output_directory*** variable set the base directory where built artifacts and the package box will be dumped, and the ***version*** variable set the Docker engine version to be installed into box (see [docker docs](https://docs.docker.com/engine/release-notes/) for futher information)

Once the package box is created, just import it into vagrant doing:

~~~
$ vagrant box add --name "Yohnah/Docker" /path/to/package.box
~~~

/path/to/package.box is the path where the resulting box can be found

Finally, confirm the package was imported on Vagrant:

~~~
$ vagrant box list
~~~

Thereafter, follow the steps in the [how to use](#how-to-use) section
