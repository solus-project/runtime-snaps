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

function extract_install_local()
{
    mkdir tmp
    pushd tmp
    cp -v $1 .
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
# extract_install_local /home/ufee1dead/Solus/linux-steam-integration/linux-steam-integration-0.6-21-1-x86_64.eopkg
extract_install steam

# Now unbugger Steam using lib not lib64..
mv "$ROOTDIR"/usr/lib/* "$ROOTDIR"/usr/lib64/.
rmdir "$ROOTDIR"/usr/lib

# Use bin/ only
mkdir "$ROOTDIR/bin"
mv "$ROOTDIR"/usr/bin/* "$ROOTDIR"/bin/.
rmdir "$ROOTDIR/usr/bin"

install -m 00755 ./steam-wrap.sh "$ROOTDIR/bin/."
install -m 00755 ./settings-wrap.sh "$ROOTDIR/bin/."


# Now lets cook a snap
cook_snap linux-steam-integration

