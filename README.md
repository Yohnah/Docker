# Begin

Welcome to this modest project, a Docker Desktop alternative on Vagrant by Hashicorp

Just run ***vagrant up*** command and get a worked Docker Desktop alternative

Debian GNU/Linux is used as OS based system for compatibily reasons among the listed [hypervisors](#hypervisor) below
___
***Note:***
Vagrant Cloud repository: [https://app.vagrantup.com/Yohnah/boxes/Docker](https://app.vagrantup.com/Yohnah/boxes/Docker)

Vagrant Cloud repository support the following providers: VirtualBox, VMWare and Parallels. If you need to get a version for other of compatible [hypervisors](#hypervisor), please see the "[Building from sources](#building-from-sources)" section for more information
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

## Compatible Operative Systems as host

* Windows 10/11
* MacOS (tested on BigSur x86_64 and higher)
* GNU/Linux

## Software

* Vagrant: <https://www.vagrantup.com/>

## Hypervisors

One of the following hypervisors must be installed:

* Virtualbox: <https://www.virtualbox.org/>
* Parallels: <https://www.parallels.com/> (only x86_64 compatible)
* Hyper-V: <https://docs.microsoft.com/en-us/virtualization/hyper-v-on-windows/about/>
* VMWare Workstation or Fusion: <https://www.vmware.com/>

## In order to build yourself

* GNU Make: <https://www.gnu.org/software/make/>
* Packer: <https://www.packer.io/>
* jq: <https://stedolan.github.io/jq/>
* Window Subsystem LInux or CygWin if Windows is used (to run the "make" command)

# Issues

If you get an issue or problem running Yohnah/Docker, please, kindly open a new issue ticket or review the current issue tickets into [issues section](https://github.com/Yohnah-org/Docker/issues) into GitHub portal. Please, be as detailed as possible 

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


# Alternative use of docker on Yohnah/Docker box

Check out the "vagrant --help" to see the specific commands after vagrant up

~~~
$ vagrant --help
$ vagrant install-docker-client
$ vagrant docker -- run hello-world
~~~

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

VMWare fusion was used to create and test the vagrant box, hence, if you detect any trouble using it on WMWare workstation or others, please, kindly report it into [issues section](https://github.com/Yohnah-org/Docker/issues)

There are several known issues when Vagrant is running using vmware_desktop provider. Please, visit <https://www.vagrantup.com/docs/providers/vmware/known-issues> for futher information.

One of those issues is a loss DNS connection when a private network is created. So if you need to access the service published by a running docker container, you will have to use the same IP address as the one used by vagrant ssh. Be aware of port conflicts with DOCKER_HOST running port

# Building from sources

Another option to use Yohnah/Box is building it from sources.

To reach it out, first of all, the code must be cloned from the git repository on GitHub:

~~~
$ git clone github.com/Yohnah-org/Docker.git
~~~

And, inside of git workspace run the following command:

## Running the GNU make command

~~~
docker/$ make
~~~

And a local box for virtualbox provider will build.

If you want to build a box for another [Hypervisor](#hypervisor) compatible, just run the make command as follows:

~~~
docker/$ make PROVIDER=<hypervisor>
~~~

Ex:
~~~
docker/$ make PROVIDER=virtualbox #default behaviour
docker/$ make PROVIDER=hyperv
docker/$ make PROVIDER=virtualbox
docker/$ make PROVIDER=parallels
~~~

Once make was done, the box can be found at /tmp/packer-build directory

## Just Packer

On the other hand, you want to build the box just using Packer, then you have to fit the following variables in:

* output_directory to set the path where packer dump the box
* docker_version to set what version of docker must be installed
* debian_version to set the version of debian to build the virtual machine golden image for the esulting box

Also, you must use the -only param to set what provider want to use:

* builder.virtualbox-iso.docker
* builder.parallels-iso.docker
* builder.vmware-iso.docker
* builder.hyperv-iso.docker

As follows:

~~~
docker/$ packer build -var "output_directory=</path/to/dump/the/box>" -var "debian_version=<version of debian>" -var "docker_version=<version of docker>" -only <builder to build the box> packer.pkr.hcl
~~~

Ex:
~~~
docker/$ packer build -var "output_directory=/tmp" -var "debian_version=11.2.0" -var "docker_version=20.10.13" -only builder.virtualbox-iso.docker packer.pkr.hcl
~~~

For getting a built virtualbox box 

## Test and use it

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
