#!/bin/sh
image="jhazelwo/pupedock"
keyname="pupkey"
opts="-oStrictHostKeyChecking=false -oUserKnownHostsFile=/dev/null"

container="`docker ps -a|grep ${image}|grep Up|awk '{print $1}'|head -1`"
test -n "${container}" || exit 2

addr="`docker inspect -f '{{.NetworkSettings.IPAddress}}' ${container}`"
test -n "${addr}" || exit 3

private_key="./.ssh/${keyname}"
test -f "${private_key}" || exit 4

ssh -l root -i $private_key $opts $addr


