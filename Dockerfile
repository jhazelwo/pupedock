FROM centos:6
MAINTAINER "John Hazelwood" <jhazelwo@users.noreply.github.com>

# https://puppetlabs.com/download-puppet-enterprise-expand-all
# curl -sSL "https://pm.puppetlabs.com/cgi-bin/download.cgi?dist=el&rel=6&arch=x86_64&ver=latest" -o ./files/puppet-enterprise-${THIS_RELEASE}.tar.gz
# curl -sSL "https://pm.puppetlabs.com/cgi-bin/download.cgi?dist=el&rel=6&arch=x86_64&ver=latest" -o ./files/puppet-enterprise-2015.2.3-el-6-x86_64.tar.gz
ENV THIS_RELEASE 2015.3.0-el-6-x86_64

# Base patching:
RUN yum clean expire-cache && yum -y install yum-utils tar which

# Copy, prepare and run Puppet installer:
ADD ./files/puppet-enterprise-${THIS_RELEASE}.tar.gz /tmp/
WORKDIR /tmp/puppet-enterprise-${THIS_RELEASE}
ADD ./files/additional-answers.txt /tmp/
RUN cat /tmp/additional-answers.txt >> ./answers/all-in-one.answers.txt
ADD ./files/update-hosts.sh /tmp/
RUN /tmp/update-hosts.sh && \
  ./puppet-enterprise-installer -a ./answers/all-in-one.answers.txt

# https://forge.puppetlabs.com/puppetlabs/stdlib
RUN /usr/local/bin/puppet module install puppetlabs-stdlib

# https://docs.puppetlabs.com/pe/latest/puppet_config.html#disabling-update-checking
RUN touch /etc/puppetlabs/puppetserver/opt-out

# https://docs.puppetlabs.com/puppetdb/latest/connect_puppet_master.html#step-2-edit-config-files
RUN /usr/local/bin/puppet config set --section=main usecacheonfailure false
RUN /usr/local/bin/puppet config set --section=main reports store,puppetdb
# Don't put these 2 settings in [main]! It triggers 'trusted facts' bug.
RUN /usr/local/bin/puppet config set --section=master storeconfigs true
RUN /usr/local/bin/puppet config set --section=master storeconfigs_backend puppetdb

# Anything For Devels:
RUN yum -y install rubygems git rsync wget unzip
RUN /usr/bin/gem install --no-ri --no-rdoc puppet-lint
RUN ln -s /etc/puppetlabs/code/environments/production/manifests/site.pp /root/
RUN ln -s /etc/puppetlabs/code/environments/production/modules /root/
RUN ln -s /var/log/puppetlabs/puppetserver/puppetserver.log /root/

# Trigger file used by init.sh.
RUN date > /root/.new

ADD ./files/init.sh /root/
CMD /root/init.sh

