#!/bin/sh

# Run on VM to bootstrap Puppet Master server

if ps aux | grep "puppet master" | grep -v grep 2> /dev/null
then
    echo "Puppet Master is already installed. Exiting..."
else
    # Install Puppet Master
	yum install -y  https://yum.puppetlabs.com/puppet-release-el-7.noarch.rpm
	yum install -y puppetserver puppetdb puppetdb-termini puppet-agent puppet-bolt

    # Configure /etc/hosts file
    echo "" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "# Host config for Puppet Master and Agent Nodes" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "10.14.14.10    puppet.example.com  puppet" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "10.14.14.11   node01.example.com  node01" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "10.14.14.12   node02.example.com  node02" | sudo tee --append /etc/hosts 2> /dev/null

    # Add optional alternate DNS names to /etc/puppet/puppet.conf
    sed -i 's/.*\[main\].*/&\ndns_alt_names = puppet,puppet.example.com/' /etc/puppetlabs/puppet/puppet.conf

    # Install some initial puppet modules on Puppet Master server
    puppet module install puppetlabs-ntp
    puppet module install puppetlabs-git
    puppet module install puppetlabs-vcsrepo

    # symlink manifest from Vagrant synced folder location
    ln -sf /vagrant/site.pp /etc/puppetlabs/code/environments/production/manifests/site.pp
	systemctl enable puppetserver --now
fi
systemctl enable puppet --now
