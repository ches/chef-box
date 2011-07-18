#!/bin/bash -eux

# chef server
if [ ! -f /etc/chef/client.pem ]; then
    perl -p -i -e 's/localhost/172.16.172.16/g' /etc/chef/server.rb
    for x in rabbitmq-server couchdb chef-solr chef-expander; do
        update-rc.d $x defaults &
        invoke-rc.d $x start &
        wait
        if [ $x == rabbitmq-server ]; then
            rabbitmqctl add_vhost /chef
            rabbitmqctl add_user chef ub3rs3kr4t
            rabbitmqctl set_permissions -p /chef chef ".*" ".*" ".*"
        fi
    done
    update-rc.d chef-server defaults 30 70
fi

# ssh keygen
export HOME=/home/vagrant
if [ ! -f $HOME/.ssh/id_rsa ]; then
    chown -R vagrant:vagrant $HOME/.ssh
    sudo -Eu vagrant ssh-keygen -q -N "" -f $HOME/.ssh/id_rsa
    cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys
    chmod go-rwsx $HOME/.ssh
    rsync -vauc $HOME/.ssh/ /vagrant/.ssh/
fi

# knife configure
if [ ! -f $HOME/.chef/knife.rb ]; then
    usermod -a -G chef vagrant
    chmod g+r /etc/chef/{validation,webui}.pem
    sudo -Eu vagrant knife configure -i -n -r $HOME --defaults
    echo '
dir = File.dirname(__FILE__)
log_level :debug
log_location STDOUT
node_name "vagrant"
client_key "#{dir}/vagrant.pem"
chef_server_url "http://172.16.172.16:4000"
cache_type "BasicFile"
cache_options :path => "#{dir}/checksums"
cookbook_path ["#{dir}/../cookbooks", "/vagrant/cookbooks"]
' | sudo -Eu vagrant tee $HOME/.chef/knife.rb
    chmod -R o-rwx $HOME/.chef
    rsync -vac $HOME/.chef/ /etc/chef/validation.pem /vagrant/.chef/
fi

# knife upload
if [ -d /vagrant/cookbooks/ ]; then
    cd /vagrant/cookbooks
    for x in $(find * -maxdepth 0 -type d); do
        sudo -Eu vagrant knife cookbook upload $x
    done
fi
if [ -d /vagrant/roles/ ]; then
    cd /vagrant/roles
    for x in $(ls | egrep ".*(rb|json)"); do
        sudo -Eu vagrant knife role from file $x
    done
fi
