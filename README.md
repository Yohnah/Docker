# Docker

Packer code to create Vagrant Box as Docker Desktop alternative.

## Requirements

### Software

* [Vagrant](https://www.vagrantup.com/)
* [Docker client binary](https://download.docker.com/) for Windows, MacOS or GNU/Linux if it's required run on host machine.

### Hypervisors

* [Virtualbox](https://www.virtualbox.org/)


## How to use

### Building from source code

---
***NOTE***

If you don't want to run the vagrant box from building the code and you want to use it from Vagrant Cloud, jump to next section ***Init vagrant box***
___

First of all, clone the repository to local workspace in your device:

~~~
$ git clone https://github.com/Yohnah/Docker.git
~~~

Once cloned, dir to docker workspace and run the following command:

~~~
Docker/$ packer build -var "output_directory=/tmp" Packer/packer.pkr.hcl 
~~~

When build finished then run the following command to add the new package box to Vagrant box workspace:

~~~
vagrant box add --name "Yohnah/Docker" /tmp/packer-build/output/boxes/docker/virtualbox/package.box
~~~

### Init vagrat box

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

After box is running, it is possible ssh to vagrant box environment.

~~~
$ vagrant ssh
~~~

And perform any ocker actions using the installed docker client within vagrant box.


## Run Docker on host

The vagrant box has exposed the 2375/tcp port (docker service port) and bind it at 127.0.0.1 loopback interface.

---
***NOTE***

If the 2375/tcp is already in use, vagrant will set up a new port. Look at it on vagrant boot verbose at boot time.

---

### Set DOCKER_HOST environment variable

So, it is possible to use docker binary client setting up the DOCKER_HOST environment variable:

~~~
On GNU/Linux or MacOs
$ export DOCKER_HOST="tcp://127.0.0.1:2375/"

On Windows CMD shell:
C:\> setx DOCKER_HOST "tcp://127.0.0.1:2375/"

On Powershell:
PS C:\> $env:DOCKER_HOST = "tcp://127.0.0.1:2375/"
~~~

### Set context on docker client

Another alternative to use the docker binary client is configuring the [docker context command](https://docs.docker.com/engine/context/working-with-contexts/).

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


Further information read the vagrant docs about [Synced folders](vagrantup.com/docs/synced-folders)
