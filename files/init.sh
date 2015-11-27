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
        /sbin/chkconfig --add $this
        /sbin/chkconfig $this on
        /sbin/service $this $1 >> /tmp/init.log
    done
}

#
yo "Booting PupEnt container, this usually takes a few minutes"
Services start

Agent() {
    echo -n "`date` Try (${1}/${2}): 'puppet agent -t',"
    puppet agent --onetime --verbose --no-daemonize >> /tmp/init.log 2>&1
    ret="${?}"
    echo " returned: ${ret}."
    return $ret
}

# If this is a brand new container don't daemonize,
#   run the puppet agent to apply systemic changes
#   then exit cleanly.
test -f /root/.new && {
    # Puppet may need a few seconds to finish booting
    #     so try three times to get a successful run.
    Agent 1 3 || Agent 2 3 || Agent 3 3 || exit 1
    Services stop
    rm -vf /root/.new
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
        yo "Shutdown trigger file found, stopping container..." | wall
        rm -fv /root/.shutdown
        Services stop
        exit 0
    }
done

