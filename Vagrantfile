# -*- mode: ruby -*-
# vi: set ft=ruby :

# You can ask for more memory and cores when creating your Vagrant machine:
# GITLAB_VAGRANT_MEMORY=2048 GITLAB_VAGRANT_CORES=4 vagrant up
MEMORY = ENV['GITLAB_VAGRANT_MEMORY'] || '1536'
CORES = ENV['GITLAB_VAGRANT_CORES'] || '2'

Vagrant.configure("2") do |config|
  config.vm.hostname = "gitlab-dev"

  config.vm.box = "precise64"
  config.vm.box_url = "http://files.vagrantup.com/precise64.box"

  # Assign this VM to a host-only network IP, allowing you to access it
  # via the IP. Host-only networks can talk to the host machine as well as
  # any other machines on the same network, but cannot be accessed (through this
  # network interface) by any external networks.
  config.vm.network :private_network, ip: "192.168.3.4"

  config.vm.network :forwarded_port, guest: 3000, host: 3000
  config.vm.network :forwarded_port, guest: 80, host: 8080

  config.vm.synced_folder ".", "/home/git", :nfs => true

  config.vm.provider :virtualbox do |v|
    # Use VBoxManage to customize the VM. For example to change memory:
    v.customize ["modifyvm", :id, "--memory", MEMORY.to_i]
    v.customize ["modifyvm", :id, "--cpus", CORES.to_i]

    if CORES.to_i > 1
      v.customize ["modifyvm", :id, "--ioapic", "on"]
    end
  end

  # Install the version of Chef by the Vagrant Omnibus
  # version is :latest or "11.4.0"
  # Note:
  # Using version "11.4.0" because that is the latest version
  # AWS OpsWorks supports
  config.omnibus.chef_version = "11.4.0"

  # Enabling the Berkshelf plugin. To enable this globally, add this configuration
  # option to your ~/.vagrant.d/Vagrantfile file
  config.berkshelf.enabled = true

  config.vm.provision :chef_solo do |chef|
    chef.json = {
      "gitlab" => {
        "env" => "development"
      },
      "phantomjs" => {
        "version" => "1.8.1"
      }
    }
    chef.run_list = [
      "apt",
      "postfix",
      "gitlab::default"
    ]
    # In case chef-solo run is failing silently
    # uncomment the line below to enable debug log level.
    # chef.arguments = '-l debug'
  end
end
