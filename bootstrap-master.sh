#!/bin/sh

# Run on VM to bootstrap Puppet Master server

if ps aux | grep "puppet master" | grep -v grep 2> /dev/null
then
    echo "Puppet Master is already installed. Exiting..."
else
    SHA256HASH="3684b8ef7b9a1bfdec60d70e18ad073f2f85bab8f4a4e6ff96d31a6b16101fa1"
	PASSWORD=$1
    SHA256HASH_C="`echo -n \"$PASSWORD\" | sha256sum | cut -f1 -d ' '`"
    if ! [ ${SHA256HASH} == ${SHA256HASH_C} ]
      then
	  echo "You need correct password to proceed further"
	  echo "${PASSWORD}"
	  echo "${SHA256HASH_C}"
	  exit 2
	fi
    # Install Puppet Master
	#yum install -y  https://yum.puppetlabs.com/puppet-release-el-7.noarch.rpm
	echo "Puppet 5 installation for now"
	yum install -y https://yum.puppet.com/puppet5-release-el-7.noarch.rpm
	yum install -y puppetserver puppetdb puppetdb-termini puppet-agent vim git bash-completion

    # Configure /etc/hosts file
    echo "" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "# Host config for Puppet Master and Agent Nodes" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "10.14.14.10    puppet.example.com  puppet" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "10.14.14.11   node01.example.com  node01" | sudo tee --append /etc/hosts 2> /dev/null && \
    echo "10.14.14.12   node02.example.com  node02" | sudo tee --append /etc/hosts 2> /dev/null

    # Add optional alternate DNS names to /etc/puppet/puppet.conf
    sed -i 's/.*\[main\].*/&\ndns_alt_names = puppet,puppet.example.com/' /etc/puppetlabs/puppet/puppet.conf

    PSPATH="/opt/puppetlabs/bin"
	mkdir -p ~/.ssh
	gpg --batch --decrypt -o ~/ssh.tgz --passphrase ${PASSWORD} /vagrant/puppetserver/files/ssh/ssh.tgz.gpg
	tar -xf ~/ssh.tgz -C  ~/.ssh
	chmod 700  ~/.ssh
	chmod 600 ~/.ssh/id_rsa
	chmod 644 ~/.ssh/id_rsa.pub
	rm ~/ssh.tgz
	cd /tmp/; git clone https://github.com/oleksandriegorov/control-init.git; cd control-init
	$PSPATH/puppet apply install.pp
	cd ~
    # Install some initial puppet modules on Puppet Master server
#	$PSPATH/puppet module install puppetlabs-concat --version 5.3.0
#	$PSPATH/puppet module install puppetlabs-stdlib --version 5.2.0
#    $PSPATH/puppet module install puppetlabs-ntp
#    $PSPATH/puppet module install puppetlabs-git
#    $PSPATH/puppet module install puppetlabs-vcsrepo
#    $PSPATH/puppet module install puppetlabs-dhcp

    # symlink manifest from Vagrant synced folder location
#    ln -sf /vagrant/site.pp /etc/puppetlabs/code/environments/production/manifests/site.pp
#	ln -s /vagrant/modules/lsys /etc/puppetlabs/code/environments/production/modules/lsys
#	sed -i 's/JAVA_ARGS=\"-Xms2g -Xmx2g/JAVA_ARGS=\"-Xms512m -Xmx512m/' /etc/sysconfig/puppetserver
#	systemctl enable puppetserver --now
fi
#systemctl enable puppet --now
