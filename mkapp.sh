#!/bin/bash
set -x

ROOTDIR="`pwd`/APP_ROOT"
BASEDIR="`pwd`"
APPS_DIR="$BASEDIR/apps"

# Bit of house keeping to ensure package managers don't jank up the rootfs
function init_root()
{
    if [[ ! -d "$ROOTDIR" ]]; then
        mkdir $ROOTDIR
    fi
}

# Dirty evil hacks to pull the raw package contents into the root dir
# without considering dependencies and all that jazz.
function extract_install()
{
    mkdir tmp
    pushd tmp
    eopkg fetch $*
    uneopkg *.eopkg
    cp -Rva install/* "$ROOTDIR/."
    popd
    rm -rf tmp
}

# Cheap and dirty, copy the named runtime meta into the root and tell it to
# bake a snap for us
function cook_snap()
{
    cp -Rv $APPS_DIR/$1/meta "$ROOTDIR/."
    snap pack "$ROOTDIR"
}

init_root

extract_install linux-steam-integration
extract_install steam

# Now unbugger Steam using lib not lib64..
mv "$ROOTDIR"/usr/lib/* "$ROOTDIR"/usr/lib64/.
rmdir "$ROOTDIR"/usr/lib

# Now lets cook a snap
cook_snap linux-steam-integration

