FROM centos:6
MAINTAINER "John Hazelwood" <jhazelwo@users.noreply.github.com>

RUN yum clean expire-cache && \
 yum -y update && \
 yum -y install wget unzip cronie openssh-server openssh-clients rsync yum-utils

# PE-Puppet deps:
RUN yum -y install dmidecode hwdata make openssl pciutils-libs \
  centos-logos libjpeg-turbo libxslt mailcap net-tools pciutils \
  initscripts kmod kmod-libs sysvinit-tools which tar rubygems git

ADD ./files/puppet-enterprise-2015.2.2-el-6-x86_64.tar.gz /tmp/
WORKDIR /tmp/puppet-enterprise-2015.2.2-el-6-x86_64
ADD ./files/additional-answers.txt /tmp/
RUN cat /tmp/additional-answers.txt >> ./answers/all-in-one.answers.txt

ADD ./files/update-hosts.sh /tmp/
RUN /tmp/update-hosts.sh && \
  ./puppet-enterprise-installer -a ./answers/all-in-one.answers.txt

ADD ./.ssh/pupkey.pub /root/.ssh/authorized_keys

RUN rm -rf /var/run/puppetlabs
RUN /usr/local/bin/puppet module install puppetlabs-stdlib

# Needed for development and testing.
RUN /usr/bin/gem install puppet-lint rspec bundler rake
RUN gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
RUN curl -sSL https://get.rvm.io | bash -s stable --ruby

# https://docs.puppetlabs.com/pe/latest/puppet_config.html#disabling-update-checking
RUN touch /etc/puppetlabs/puppetserver/opt-out

# https://docs.puppetlabs.com/puppetdb/latest/connect_puppet_master.html#step-2-edit-config-files
RUN /usr/local/bin/puppet config set --section=main usecacheonfailure false
RUN /usr/local/bin/puppet config set --section=main reports store,puppetdb
# Don't put these 2 settings in [main]! It triggers 'trusted facts' bug.
RUN /usr/local/bin/puppet config set --section=master storeconfigs true
RUN /usr/local/bin/puppet config set --section=master storeconfigs_backend puppetdb

# Trigger file used by init.sh.
RUN date > /root/.new

ADD ./files/init.sh /root/
CMD /root/init.sh

