#!/bin/sh

modules="-v /media/sf_GitHub:/mnt"

docker run --hostname=pe-puppet.localdomain ${modules} --rm jhazelwo/pupedock



