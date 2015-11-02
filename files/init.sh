#!/bin/sh

# Let user CTRL-C container boot.
trap "exit 2" 2

yo() { # dawg
    echo "`date` $@"
}

yo "init.sh; Booting PupEnt container, this will take a few minutes"
yo "You will see a 'Puppet is up' message when done."
service sshd start
yo "You may log in with ./Login.sh while the Puppet services are started."
service pe-activemq start
service mcollective start
service pe-postgresql start
service pe-puppetdb start



service pe-console-services start
service pe-nginx start

/sbin/service pe-puppetserver status
/sbin/chkconfig pe-puppetserver
/sbin/chkconfig --add pe-puppetserver
/sbin/chkconfig pe-puppetserver on
/sbin/service pe-puppetserver status
/sbin/service pe-puppetserver start


yo "Puppet is up."
yo "You may stop this container with ctrl-c,"
yo "with 'docker stop', or by killing the "
yo "nginx, java and postmaster processes."
#
# Every n seconds check for Puppet services,
#   if they've all stopped then stop the container.
while [ 1 ]; do
    sleep 10
    pgrep 'nginx|java|postmaster' >/dev/null || exit 1
done

