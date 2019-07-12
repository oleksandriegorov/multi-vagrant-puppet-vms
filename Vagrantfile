# vi: set ft=ruby :

# Builds Puppet Master and multiple Puppet Agent Nodes using JSON config file
# Author: Gary A. Stafford

# read vm and chef configurations from JSON files
nodes_config = (JSON.parse(File.read("nodes.json")))['nodes']

VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "bento/centos-7"

  nodes_config.each do |node|
    node_name   = node[0] # name of node
    node_values = node[1] # content of node

    config.vm.define node_name do |config|    
      # configures all forwarding ports in JSON array
      ports = node_values['ports']
      ports.each do |port|
        config.vm.network :forwarded_port,
          host:  port[':host'],
          guest: port[':guest'],
          id:    port[':id']
      end

      config.vm.provider :virtualbox do |vb|
        vb.customize ["modifyvm", :id, "--memory", node_values[':memory']]
        vb.customize ["modifyvm", :id, "--name", node_name]
      end


      config.vm.hostname = node_name
      config.vm.network :private_network, ip: node_values[':ip']
      # No need for provisioner if it is PXE boot
      if node_values[':boot'] == 'network' then
        config.vm.box = "jtyr/pxe"
        config.vm.box_version = "1"
        config.vm.boot_timeout = 1
      else
        # Puppet server has some private files; use your password
        if node_values[':askpass'] == 'true' && ARGV[0] == 'up' then
          if Dir.glob("#{File.dirname(__FILE__)}/.vagrant/machines/#{node_name}/virtualbox/id").empty? || ARGV[1] == '--provision' then
            print "Enter password you have got from your mate to decrypt some secret files: "
            password = STDIN.noecho(&:gets).chomp
            print "\n"
            config.vm.provision :shell, :path => node_values[':bootstrap'], :args => [password]
          else
            config.vm.provision :shell, :path => node_values[':bootstrap']
          end
        # if this is not Puppet server - do not ask password
        else
          config.vm.provision :shell, :path => node_values[':bootstrap']
        end
      end

    end
  end
end
