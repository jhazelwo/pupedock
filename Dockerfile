FROM centos:7
MAINTAINER jhazelwo@github

RUN yum clean expire-cache && \
 yum -y update && \
 yum -y install wget unzip

RUN yum -y install cronie

ADD ./files/puppet-ent*.gz /tmp/

WORKDIR /tmp/puppet-enterprise-2015.2.2-el-7-x86_64
#RUN ./puppet-enterprise-installer -a ./answers/all-in-one.answers.txt

# PE-Puppet deps:
RUN yum -y install dmidecode hwdata make openssl pciutils-libs centos-logos libjpeg-turbo libxslt mailcap net-tools pciutils initscripts kmod kmod-libs sysvinit-tools

RUN echo exit > /sbin/chkconfig
ADD ./files/service /sbin/service

