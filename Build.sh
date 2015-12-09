#!/bin/sh -e
image="jhazelwo/pupedock"
modules="-v /media/sf_GitHub:/mnt"
name="pupedock"

yo(){ echo "`date` $@";}

echo "`date` Building IMAGE '${image}':"
docker inspect $name >/dev/null 2>&1 && docker rm -f $name
docker build --force-rm=true -t "${image}" . || exit $?

[ "x$1" = "xclean" ] && {
    echo "`date` Build complete, cleaning up any orphaned layers:"
    for this in `/usr/bin/docker images |grep '<none>'|awk '{print $3}'`; do
        /usr/bin/docker rmi $this
    done
}

yo "Doing initial run to create CONTAINER from IMAGE"
docker run --name=$name --hostname=pe-puppet.localdomain $modules $image

yo "Done!"

