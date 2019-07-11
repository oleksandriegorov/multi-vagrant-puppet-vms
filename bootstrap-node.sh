#!/bin/sh

# Run on VM to bootstrap Puppet Agent nodes

if ps aux | grep "puppet agent" | grep -v grep 2> /dev/null
then
    echo "Puppet Agent is already installed. Moving on..."
else
    # Install Puppet Master
	yum install -y https://yum.puppet.com/puppet5-release-el-7.noarch.rpm
	yum install -y puppet-agent
fi

if cat /etc/crontab | grep puppet 2> /dev/null
then
    echo "Puppet Agent is already configured. Exiting..."
else
    # Configure /etc/hosts file
    echo "" | tee --append /etc/hosts 2> /dev/null && \
    echo "# Host config for Puppet Master and Agent Nodes" | tee --append /etc/hosts 2> /dev/null && \
    echo "10.14.14.10    puppet.example.com  puppet" | tee --append /etc/hosts 2> /dev/null && \
    echo "10.14.14.11   node01.example.com  node01" | tee --append /etc/hosts 2> /dev/null && \
    echo "10.14.14.12   node02.example.com  node02" | tee --append /etc/hosts 2> /dev/null

    # Add agent section to /etc/puppet/puppet.conf
    echo "" && echo -e "[agent]\nserver=puppet" | tee --append /etc/puppetlabs/puppet/puppet.conf
	
	systemctl enable puppet --now
fi
