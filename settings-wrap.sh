#!/bin/bash

OUR_DRIVER_PATHS="/var/lib/snapd/lib/gl:/usr/lib/glx-provider/default"
export LIBGL_DRIVERS_PATH="$OUR_DRIVER_PATHS:/usr/lib/dri"
export LD_LIBRARY_PATH="$OUR_DRIVER_PATHS"

export PATH="/bin:$PATH"

exec "$SNAP"/bin/lsi-settings
