#!/bin/sh

echo "`head -n 1 /etc/hosts|awk '{print $1}'` pe-puppet.localdomain pe-puppet pe-puppetdb puppetdb puppet" >> /etc/hosts 

