#!/bin/sh

# /root/init.sh - Start container services
# "John Hazelwood" <jhazelwo@users.noreply.github.com>

# Let user CTRL-C container boot.
trap "exit 2" 2

# Services to start on boot
services="sshd
pe-activemq
mcollective
pe-postgresql
pe-puppetdb
pe-console-services
pe-nginx
pe-puppetserver"

# Path to production modules
prodmod="/etc/puppetlabs/code/environments/production/modules"


# Bark function
yo() { echo "`date` $@"; }

Services() {
    for this in $services; do
        yo "${1} ${this}"
        /sbin/service $this $1 >> /tmp/init.log
    done
}

#
yo "Booting PupEnt container, this will take a few minutes"

Services start
#for this in $services; do
#    yo "Starting ${this}"
#    /sbin/service $this restart >> /tmp/init.log
#done

# If this is a brand new container don't daemonize,
#   run the puppet agent to apply systemic changes
#   then exit cleanly.
test -f /root/.new && {
    puppet agent -t >> /tmp/init.log
    rm -vf /root/.new
    Services stop
#    for this in $services; do
#        /sbin/service $this stop >> /tmp/init.log
#    done
    yo "Container creation complete!"
    yo "Use 'docker start pupedock' to launch, then ./Login.sh to log in."
    exit 0
}
yo "All Puppet services are up, container ready."

# Wait forever for the shutdown trigger file.
#   If found, exit cleanly.
while [ 1 ]; do
    sleep 1
    chown -R pe-puppet:pe-puppet $prodmod
    test -f /root/.shutdown && {
        yo "Shutdown trigger file found, stopping."
        rm -fv /root/.shutdown
        Services stop
        exit 0
    }
done

