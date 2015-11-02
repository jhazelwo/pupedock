#!/bin/sh
image="jhazelwo/pupedock"
keyname="pupkey"

test -f ./.ssh/$keyname || ssh-keygen -t dsa -b 1024 -f ./.ssh/$keyname -P ''

echo "`date` Building ${image}:"
docker build --force-rm=true -t "${image}" . || exit $?

[ "x$1" = "xclean" ] && {
	echo "`date` Build complete, cleaning up any orphaned layers:"
	for this in `/usr/bin/docker images |grep '<none>'|awk '{print $3}'`; do
	        /usr/bin/docker rmi $this
	done
}

#echo "`date` Done! Use ./Go.sh to start a container from this image."
echo "`date` Done."

