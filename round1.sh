#!/bin/bash

# ROUND 1: Try making a snap out of a bare bones root

if [[ "$EUID" != "0" ]]; then
    echo "I .. AM... not g.. ROOT"
    exit 1
fi

 . common.sh

ROOTDIR="$WORKDIR/BASE_ROOT"

# Bit of house keeping to ensure package managers don't jank up the rootfs
function init_root()
{
    if [[ ! -d "$ROOTDIR" ]]; then
        mkdir -p $ROOTDIR
    fi

    mkdir -p $ROOTDIR/run/lock
    mkdir -p $ROOTDIR/var
    ln -s ../run/lock $ROOTDIR/var/lock
    ln -s ../run $ROOTDIR/var/run
}

# Make the rootfs happy enough for snapd
function snappify()
{
    # Needed in general for everyone
    mkdir -p $ROOTDIR/var/lib/snapd
    mkdir -p $ROOTDIR/var/log
    mkdir -p $ROOTDIR/var/snap
    mkdir -p $ROOTDIR/lib/modules
    mkdir -p $ROOTDIR/usr/src
    mkdir -p $ROOTDIR/usr/lib/snapd
    mkdir -p $ROOTDIR/media
    mkdir -p $ROOTDIR/snap

    # OK so in theory we could install snapd inside but meh.
    install -m 00755 /usr/lib/udev/snappy-app-dev $ROOTDIR/lib/udev/.

    # UGLY HACKS: Get this fixed in snapd confinement policy!
    # We use lib64, snapd defines "lib" within the target
    rm $ROOTDIR/lib
    mv $ROOTDIR/lib64 $ROOTDIR/lib
    ln -sv lib $ROOTDIR/lib64
    # Repeat of the above
    rm $ROOTDIR/usr/lib
    mv $ROOTDIR/usr/lib64 $ROOTDIR/usr/lib
    ln -sv lib $ROOTDIR/usr/lib64
}

# Desparately attempt to install a package
function install_package()
{
    eopkg install -y -D "$ROOTDIR" --ignore-comar $*
}

# Similar to install_package, just uses -c notation.
function install_component()
{
    install_package -c $*
}

# Ugly, add a repo to the directory
function add_repo()
{
    eopkg add-repo -D "$ROOTDIR" "Solus" $1
}

# Placeholder until we can have custom packages for this runtime
# Basically the LDM detection will fail and the default mesa symlinks will
# be put in place.
function configure_pending()
{
    # Update ldconfig now
    chroot "$ROOTDIR" /sbin/ldconfig -X

    # Ensure SSL certificates work
    chroot "$ROOTDIR" c_rehash

    # Update mime cache
    chroot "$ROOTDIR" update-mime-database /usr/share/mime

    # This also needs a better story, maybe just running eopkg configure pending eh? :)
    for dirn in "$ROOTDIR"/usr/share/icons/*; do
        gtk-update-icon-cache -f "$dirn"
    done

    # Update font cache
    chroot "$ROOTDIR" fc-cache -fv

    # At this point lets seal it off and stick in our overriden files
    cp -Rv "$BASEDIR/support_assets"/* "$ROOTDIR/."
}

function clean_root()
{
    # Nuke system files that take up space we're not wanting to use..
    rm -rf "$ROOTDIR/usr/share/doc"
    rm -rf "$ROOTDIR/usr/share/man"
    rm -rf "$ROOTDIR/usr/share/info"

    # Clean out package manager noise
    rm -rf "$ROOTDIR/var/lib/eopkg"
    rm -rf "$ROOTDIR/var/cache/eopkg"

    # Clean out dbs+cruft
    rm -rf "$ROOTDIR/var/db"
    rm -rf "$ROOTDIR/var/log"

    # Clean up other unneeded dudes from qt bits
    rm -rf "$ROOTDIR/usr/lib64/kconf_update_bin"
    rm -rf "$ROOTDIR/usr/share/kconf_update"

    # If we need these then we'll restore them..
    rm -rf "$ROOTDIR/usr/share/locale"

    # Nuke accidental .a fatties
    rm "$ROOTDIR/usr/lib64"/*.a
    rm "$ROOTDIR/usr/lib32"/*.a

    rm -rf "$ROOTDIR/etc/NetworkManager"
    rm -rf "$ROOTDIR/etc/systemd"
    rm -rf "$ROOTDIR/etc/X11"
    rm -rf "$ROOTDIR/lib/xtables"
    rm -rf "$ROOTDIR/lib/security"
    rm -rf "$ROOTDIR/usr/lib/ModemManager"
    rm -rf "$ROOTDIR/usr/lib/network-manager"
    rm -rf "$ROOTDIR/usr/lib/NetworkManager"
    rm -rf "$ROOTDIR/usr/lib32/NetworkManager"
    rm -rf "$ROOTDIR/usr/lib/cups"
    rm -rf "$ROOTDIR/usr/lib/pulse-10.0"
    rm -rf "$ROOTDIR/usr/lib/udev/rules.d"
    rm -rf "$ROOTDIR/usr/lib/systemd"
    rm -rf "$ROOTDIR/usr/lib/sysusers.d"
    rm -rf "$ROOTDIR/usr/lib/tmpfiles.d"
    rm -rf "$ROOTDIR/usr/share/base-layout"
    rm -rf "$ROOTDIR/usr/share/bash-completion"
    rm -rf "$ROOTDIR/usr/share/gettext"
    rm -rf "$ROOTDIR/usr/share/gdb"

    # Clean up some unnecessary setuid crap
    rm -v "$ROOTDIR/bin/mount"
    rm -v "$ROOTDIR/bin/umount"
    rm -v "$ROOTDIR/sbin/unix_chkpwd"
    rm -v "$ROOTDIR/usr/bin/ksu"
    rm -v "$ROOTDIR/usr/bin/pkexec"
    rm -v "$ROOTDIR/usr/bin/wall"
    rm -v "$ROOTDIR/usr/lib/dbus-1.0/dbus-daemon-launch-helper"
    rm -v "$ROOTDIR/usr/lib/polkit-1/polkit-agent-helper-1"
    rm -rf "$ROOTDIR/var/spool/cups/tmp"

    # Fix avx2 links
    ln -sv avx2 "$ROOTDIR/usr/lib64/haswell"
    ln -sv avx2 "$ROOTDIR/usr/lib32/haswell"
}

# Cheap and dirty, copy the named runtime meta into the root and tell it to
# bake a snap for us
function cook_snap()
{
    cp -Rv $RUNTIME_DIR/$1/meta "$ROOTDIR/."
    snap pack "$ROOTDIR"
}

set -e
set -x

# Bring up the root tree
init_root

# Let's get a repo going.
add_repo "https://packages.solus-project.com/unstable/eopkg-index.xml.xz"

# Must have our baselayout first.
install_package baselayout --ignore-safety

# Now lets fire in our core component, i.e. a working system.
# Totally ignore system.base safety to minimise the system
install_package --ignore-safety $(cat pkgs/base)

# Now install our graphical packages
install_package --ignore-safety $(cat pkgs/gui)

# Lastly, prep our runtime packages (+emul32 stuff)
install_package --ignore-safety $(cat pkgs/gaming)

# Cosmetics, install breeze theme for integration, WITHOUT qt dependency
install_package --ignore-safety --ignore-dependency breeze-gtk-theme

# Our override directories.
build_one glew16
build_one libvpx1

# Override glibc with our custom glibc
build_one glibc

# Now layer in our new shiny mesalib
build_one mesa

# Now install all of our packages to our app root
install_package $PACKAGE_OUT_DIR/*.eopkg --ignore-safety

rm -rf "$PACKAGE_OUT_DIR"

# Ensure everything is good to go
configure_pending

# TODO: Lock the root, configure it

# Now lets clean the rootfs out
clean_root

# Make snapd happy
snappify

# Now lets cook a snap
cook_snap gaming
