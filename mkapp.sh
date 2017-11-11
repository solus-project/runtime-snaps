#!/bin/bash
if [[ "$EUID" != "0" ]]; then
    echo "I .. AM... not g.. ROOT"
    exit 1
fi

 . common.sh

ROOTDIR="$WORKDIR/APP_ROOT"


# Bit of house keeping to ensure package managers don't jank up the rootfs
function init_root()
{
    if [[ ! -d "$ROOTDIR" ]]; then
        mkdir -p $ROOTDIR
    fi

    if [[ ! -d "$PACKAGE_OUT_DIR" ]]; then
        mkdir -p "$PACKAGE_OUT_DIR"
    fi
}

# Cheap and dirty, copy the named runtime meta into the root and tell it to
# bake a snap for us
function cook_snap()
{
    cp -Rv $APPS_DIR/$1/meta "$ROOTDIR/."
    snap pack "$ROOTDIR"
}

set -x
set -e

init_root

build_one linux-steam-integration
build_one steam
build_one lsb-release
build_one zenity

# Now install all of our packages to our app root
for i in $PACKAGE_OUT_DIR/*.eopkg ; do
    extract_install_local $i
done

rm -rf "$PACKAGE_OUT_DIR"

# Now lets cook a snap
cook_snap linux-steam-integration

