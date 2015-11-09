# pupedock "Puppy Doc"

## Enterprise Puppet in a Docker container

#### Using `CentOS:6`, because SystemD is dumber than Puppet.

This beast can take quite a while to compile.

Not counting the time it takes to 'docker pull' the CentOS image, on my Linux
VM (2x2.60GHz, 3GB RAM) a brand new `./Build clean` takes me about `23m8.931s`
; and yes 98% of that time is waiting for Puppet.

### Usage:

