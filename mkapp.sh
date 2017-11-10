#!/bin/bash
if [[ "$EUID" != "0" ]]; then
    echo "I .. AM... not g.. ROOT"
    exit 1
fi

BASEDIR="`pwd`"
WORKDIR="$BASEDIR/WORKDIR"
ROOTDIR="$WORKDIR/APP_ROOT"
APPS_DIR="$BASEDIR/apps"
PACKAGE_OUT_DIR="$WORKDIR/PACKAGES"
PACKAGE_IN_DIR="$BASEDIR/support_packages"

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

# Build a single package
function build_one()
{
    local pkg="$1"
    local workdir="$PACKAGE_OUT_DIR/$pkg"
    local sourcedir="$PACKAGE_IN_DIR/$pkg"

    mkdir -p "$workdir"
    mkdir -p "$sourcedir"

    pushd $workdir
    solbuild -p unstable-x86_64 build $sourcedir/package.yml
    rm -fv *dbginfo*.eopkg || :
    mv *.eopkg "$PACKAGE_OUT_DIR/."
    popd
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

# Now install all of our packages to our app root
for i in $PACKAGE_OUT_DIR/*.eopkg ; do
    extract_install_local $i
done

# Now lets cook a snap
cook_snap linux-steam-integration

