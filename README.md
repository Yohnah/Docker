# Docker

Packer code to create a Vagrant Box as a Docker Desktop alternative.

This box is built using Alpine Linux as image base from Yohnah/Alpine box at Vagrant Cloud, because the resulting package.box size is very tiny, including the docker engine installed in (192Mb aprox.)

Vagrant Cloud repository: [https://app.vagrantup.com/Yohnah/boxes/Docker](https://app.vagrantup.com/Yohnah/boxes/Docker)


## Requirements

### Software

* [Vagrant](https://www.vagrantup.com/)
* [Docker client binary](https://download.docker.com/) for Windows, MacOS or GNU/Linux if it's required run on host machine.

### Hypervisors

* [Virtualbox](https://www.virtualbox.org/)

## How to use

### Init vagrant box

Once all requirements are met, the following command must be run:

- Vagrant init to create the proper Vagrantfile in current directory

~~~
$ vagrant init Yohnah/Docker
~~~

- Raise the box up (and download the vagrant box from Vagrant Cloud if not build such as above)

~~~
$ vagrant up

or

$ vagrant up --provider <hypervisor>
~~~

---
***NOTE***

The box can be found at [https://app.vagrantup.com/Yohnah/boxes/Docker](https://app.vagrantup.com/Yohnah/boxes/Docker)

---

When box is running, ssh is possible

~~~
$ vagrant ssh
~~~

And perform any docker actions using the included docker client within the vagrant box.

### Building from source code

---
***NOTE***

If you don't want to build the vagrant package box, so ignore this step
___

First of all, clone the repository to local workspace in your device:

~~~
$ git clone https://github.com/Yohnah/Docker.git
~~~

Once cloned, dir to git workspace and run the following command:

~~~
Docker/$ packer build -var "output_directory=/tmp" Packer/packer.pkr.hcl 
~~~

When build finished then run the following command to add the new package box to Vagrant box workspace:

~~~
vagrant box add --name "Yohnah/Docker" /tmp/packer-build/output/boxes/docker/virtualbox/package.box
~~~

## Run Docker client on host connecting to guest machine

---
***NOTE***

If you don't want to use the client docker binary on your host device, so ignore this section
___

### Installing the client binary


Install the docker binary client relative to your host operative system for downloading the compress file from Docker and uncompress it, such as (replace \<version-to-download\> with the appropiate version):

- Installing on Windows (on PowerShell)

~~~
PS > echo "Downloading docker client binary"
PS > Invoke-WebRequest -Uri https://download.docker.com/win/static/stable/x86_64/docker-<version-to-download>.zip -OutFile "$env:TEMP/docker.zip"
PS > echo "Create a directory for docker"
PS > mkdir C:\Docker
PS > echo "Uncompress onto docker directory"
PS > Expand-Archive -LiteralPath "$env:TEMP/docker.zip" -DestinationPath "C:\Docker"
PS > echo "Set PATH environment variable"
PS > $env:Path += "C:\Docker"
~~~

So, run it as:

~~~
PS > docker.exe

or (If not set the PATH environment variable)

PS > C:\Docker\docker.exe
~~~

---
***NOTE***

In order to permanent set the PATH variable and not be ephimeral, read the Microsoft documentation on Section "[Saving changes to environment variables](https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_environment_variables?view=powershell-7.1#saving-changes-to-environment-variables)"

---

- Installing on MacOS

~~~
$ echo "Downloading docker client binary"
$ curl https://download.docker.com/mac/static/stable/x86_64/docker-<version-to-download>.tgz > /tmp/docker.tgz
$ echo "Uncompress onto /usr/local"
$ sudo tar -xzvf /tmp/docker.tgz -C /usr/local
$ echo "Link docker client binary"
$ sudo ln -sf /usr/local/docker/docker /usr/local/bin/docker
~~~

So, run it as:

~~~
$ docker
~~~

- Installing on GNU/Linux

~~~
$ echo "Downloading docker client binary"
$ curl https://download.docker.com/mac/static/stable/x86_64/docker-<version-to-download>.tgz > /tmp/docker.tgz
$ echo "Uncompress onto /usr/local"
$ sudo tar -xzvf /tmp/docker.tgz -C /usr/local
$ echo "Link docker client binary"
$ sudo ln -sf /usr/local/docker/docker /usr/local/bin/docker
~~~

So, run it as:

~~~
$ docker
~~~

### Set DOCKER_HOST environment variable

---
***NOTE***

The vagrant box has exposed the 2375/tcp port (docker service port) and bind it at 127.0.0.1 loopback interface.

If the 2375/tcp is already in use, vagrant will set up a new port. Look at it on vagrant boot verbose at boot time.

---

To configure the docker binary client it need to set up the DOCKER_HOST environment variable:

~~~
On GNU/Linux or MacOs
$ export DOCKER_HOST="tcp://127.0.0.1:2375/"

On Windows CMD shell:
C:\> setx DOCKER_HOST "tcp://127.0.0.1:2375/"

On Powershell:
PS C:\> $env:DOCKER_HOST = "tcp://127.0.0.1:2375/"
~~~

### Set context into docker client

The alternative is to configure the [docker context command](https://docs.docker.com/engine/context/working-with-contexts/).

Example:

~~~
$ docker context create vagrant --description "Docker connection by vagrant box using 2375 port" --docker "host=tcp://127.0.0.1:2375/"
~~~


## Mounting host directories on Vagrant box

By default, the following directories are mounted:

- USERPROFILE environment variable if host SO is Windows.
- HOME environment variable if host SO is GNU/Linux
- HOME environment variable if host SO is MacOs

---
***NOTE***

The default mounted directories are mounted as the environent variables on host was set.

### Adding custom mount directories

In order to mount custom host directories within the running vagrant box a [synced folder](https://www.vagrantup.com/docs/synced-folders) must be set in Vagrantfile at configure section.

Example:
~~~
Vagrant.configure("2") do |config|
  # other config here

  config.vm.synced_folder "/path/on/host", "/path/on/vagrant/box"
  
end
~~~

Further information read the vagrant docs about [Synced folders](https://www.vagrantup.com/docs/synced-folders)

## Exposing services ports

One of requirements to work with Docker is get access to exposed docker services running on guest from host device.

To reach it out, the package box has already configured the following Vagrantfile command within vagrant configure section:

~~~
Vagrant.configure("2") do |config|
  # other config here

  config.vm.network "private_network", type: "dhcp"
  
end
~~~

As see, the private_network is configure to get an auto assigned IP address provided by hypervisor. To know what IP address was set, just the following vagrant command may be run:

~~~
$ vagrant ssh -- get-ips.sh
~~~

Anyway, if other IP addresses shoud be set, it can be configure using the [private_network](https://www.vagrantup.com/docs/networking/private_network) or [public_network](https://www.vagrantup.com/docs/networking/public_network) vagrant config attributes within Vagrantfile manifest.

