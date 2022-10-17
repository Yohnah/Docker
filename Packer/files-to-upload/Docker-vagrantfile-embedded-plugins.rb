module Docker
    class DockerCli < Vagrant.plugin(2, :command)
        def self.synopsis
          "Docker cli shortcut to call the installed docker cli on guest"
        end
        def execute
          opts = OptionParser.new do |o|
            o.banner = "Usage: vagrant docker -- <docker arguments>"
            o.separator ""
            o.separator "Example:"
            o.separator "$ vagrant docker -- run hello-world"
            o.separator "      The command \"vagrant docker -- init\" match \"docker init\" on docker cli standard"
            o.separator ""
            o.separator "Options:"
            o.separator ""
          end
      
          argv = parse_options(opts)
          return if !argv
      
          with_target_vms(nil, single_target: true) do |vm|
            env = vm.action(:ssh_run, ssh_run_command: "cd /vagrant; docker #{argv.join(" ")}", tty: true,)
            status = env[:ssh_run_exit_status] || 0
          end
      
        end
      end
      
      class Plugin < Vagrant.plugin("2")
        name "Docker parser"
        description "Docker parser"
        command "docker" do
          DockerCli
        end
      end

      class InstallDockerCli < Vagrant.plugin(2, :command)
        def self.synopsis
          "Docker cli shortcut to install docker binaries on host"
        end
        def execute
          opts = OptionParser.new do |o|
            o.banner = "Usage: vagrant install-docker-client"
            o.separator ""
            o.separator "Example:"
            o.separator "$ vagrant install-docker-client"
            o.separator "Options:"
            o.separator ""
          end
      
          argv = parse_options(opts)
          return if !argv
      
          with_target_vms(nil, single_target: true) do |vm|
            env = vm.action(:ssh_run, ssh_run_command: ". /etc/profile; install-docker-cli.sh", tty: true,)
            status = env[:ssh_run_exit_status] || 0
          end
      
        end
      end
      
      class Plugin < Vagrant.plugin("2")
        name "Install Docker binary client"
        description "Install Docker binary client"
        command "install-docker-client" do
          InstallDockerCli
        end
      end

      class UnInstallDockerCli < Vagrant.plugin(2, :command)
        def self.synopsis
          "Docker cli shortcut to uninstall docker binaries on host"
        end
        def execute
          opts = OptionParser.new do |o|
            o.banner = "Usage: vagrant uninstall-docker-client"
            o.separator ""
            o.separator "Example:"
            o.separator "$ vagrant uninstall-docker-client"
            o.separator "Options:"
            o.separator ""
          end
      
          argv = parse_options(opts)
          return if !argv
      
          with_target_vms(nil, single_target: true) do |vm|
            env = vm.action(:ssh_run, ssh_run_command: ". /etc/profile; uninstall-docker-cli.sh", tty: true,)
            status = env[:ssh_run_exit_status] || 0
          end
      
        end
      end
      
      class Plugin < Vagrant.plugin("2")
        name "Uninstall Docker binary client"
        description "Uninstall Docker binary client"
        command "uninstall-docker-client" do
          UnInstallDockerCli
        end
      end
end