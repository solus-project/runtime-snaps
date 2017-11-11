#!/bin/bash

BASEDIR="`pwd`"
WORKDIR="$BASEDIR/WORKDIR"
ROOTDIR="$WORKDIR/APP_ROOT"
APPS_DIR="$BASEDIR/apps"
PACKAGE_OUT_DIR="$WORKDIR/PACKAGES"
PACKAGE_IN_DIR="$BASEDIR/support_packages"
RUNTIME_DIR="$BASEDIR/runtimes"

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

