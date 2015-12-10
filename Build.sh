#!/bin/sh
image="jhazelwo/pupedock"
modules="-v /media/sf_GitHub:/mnt"
name="pupedock"

yo(){ echo "`date` $@";}

echo "`date` Building IMAGE '${image}':"
docker rm -f $name 2>/dev/null
docker build --force-rm=true -t "${image}" . || exit $?

[ "x$1" = "xclean" ] && {
    echo "`date` Build complete, cleaning up any orphaned layers:"
    for this in `/usr/bin/docker images |grep '<none>'|awk '{print $3}'`; do
        /usr/bin/docker rmi $this
    done
}

yo "Doing initial run to create CONTAINER from IMAGE"
docker run -P --expose=8140 --name=$name --hostname=pe-puppet.localdomain $modules $image

yo "Done!"

