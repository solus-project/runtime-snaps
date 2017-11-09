#!/bin/bash

OUR_DRIVER_PATHS="/var/lib/snapd/lib/gl/32:/var/lib/snapd/lib/gl:/usr/lib/glx-provider/default:/usr/lib32/glx-provider/default"
export LIBGL_DRIVERS_PATH="$OUR_DRIVER_PATHS:/usr/lib/dri:/usr/lib32/dri"
export LD_LIBRARY_PATH="$OUR_DRIVER_PATHS"

export PATH="/bin:$PATH"

"$SNAP"/bin/lsi-settings
