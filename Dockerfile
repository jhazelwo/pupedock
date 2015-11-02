FROM centos:6
MAINTAINER "John Hazelwood" <jhazelwo@users.noreply.github.com>

RUN yum clean expire-cache && \
 yum -y update && \
 yum -y install wget unzip cronie openssh-server openssh-clients

# PE-Puppet deps:
RUN yum -y install dmidecode hwdata make openssl pciutils-libs \
  centos-logos libjpeg-turbo libxslt mailcap net-tools pciutils \
  initscripts kmod kmod-libs sysvinit-tools which tar

ADD ./files/puppet-enterprise-2015.2.2-el-6-x86_64.tar.gz /tmp/
WORKDIR /tmp/puppet-enterprise-2015.2.2-el-6-x86_64
ADD ./files/additional-answers.txt /tmp/
RUN cat /tmp/additional-answers.txt >> ./answers/all-in-one.answers.txt

ADD ./files/update-hosts.sh /tmp/
RUN /tmp/update-hosts.sh && \
  ./puppet-enterprise-installer -a ./answers/all-in-one.answers.txt

ADD ./.ssh/pupkey.pub /root/.ssh/authorized_keys

RUN rm -rf /var/run/puppetlabs

ADD ./files/init.sh /root/
CMD /root/init.sh

