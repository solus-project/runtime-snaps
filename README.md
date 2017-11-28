runtime-snaps
=============

Combining the [Solus](https://solus-project.com) runtime and [Linux Steam Integration](https://github.com/solus-project/linux-steam-integration) project with [Snaps](https://snapcraft.io/) for universal gaming

This is currently a **Work In Progress**.

### Why what now?

This is an ongoing effort to produce snaps to provide the Steam* client, Linux Steam Integration project,
and Solus packages to create a true "universal app" variant of Steam that will work
on every Linux distribution in the same way, while mitigating many of the runtime
issues.

This isn't just a "native Steam" effort, LSI is a highly complex project that seeks
to replace the runtime almost entirely, and fix many issues. Integrating LSI is
also a large undertaking - thus Solus is now seeking to share our work on our own
runtime and LSI implementation with the rest of the Linux world for a pain-free
and consistent gaming experience.

A large element of this is also to help developers and studios targeting Linux
as a platform to have a singular target that would work across all Linux distributions,
and provide peace of mind that their games would work as **intended**. Additionally,
as the keepers of LSI, we can rapidly deploy changes to LSI and the runtime to better
support the games and alleviate regressions before they hit users.

runtime-snaps is a [Solus project](https://solus-project.com/)

![logo](https://build.solus-project.com/logo.png)

### Planned Usage

Runtimes:

 - `solus-runtime-gaming`

Applications:

 - `linux-steam-integration` + `steam` (single snap)

Note that for now we'll not be focusing on strict confinement, so the snaps
should be installed with `--devmode` until such point as proper confinement
is feasible.

We are not currently planning on making an SDK available, as the runtime will
primarily be derived from the Solus repositories, with minor layering happening
within the local runtimes.

As and when we have the core components in place we can start discussions around
SDK + debugging availability.



How to build and run
====================

You must be on Solus to **build** these snaps. You do not need to be on Solus
to **run** these snaps.

### Dependencies

 - snapd 2.29.2 + patches
 - solbuild (ensure this has been initialised on `unstable-x86_64`)

### `snapd` patches

 - https://github.com/snapcore/snapd/commit/ec4f3c0774620dd2bb6df765b337fa8a67d2afc8 ([patch](https://github.com/snapcore/snapd/commit/ec4f3c0774620dd2bb6df765b337fa8a67d2afc8.patch))
 - https://github.com/snapcore/snapd/pull/4207 ([patch](https://patch-diff.githubusercontent.com/raw/snapcore/snapd/pull/4207.patch))

**Note**: All of these patches are in Solus

After installing the relevant snapd, ensure your apparmor rules are applied and snapd has been
restarted. Be lazy, reboot. People do it.

For Ubuntu users you may use the [Snappy Edge PPA](https://launchpad.net/~snappy-dev/+archive/ubuntu/edge)

## Install from the store

```
sudo snap install --edge solus-runtime-gaming
sudo snap install --devmode --edge linux-steam-integration
snap run linux-steam-integration
```

### Build solus-runtime-gaming (Solus only)

```bash
sudo ./round1.sh
````

### Build linux-steam-integration (Solus only)

```bash
sudo ./mkapp.sh
```

### Installation (custom build)

You must first remove the existing installs if you've already run this step before:

```bash
sudo snap remove solus-runtime-gaming linux-steam-integration
```

The installation order is important, as LSI depends on the base runtime snap:

```bash
sudo snap install --dangerous solus-runtime-gaming*.snap
sudo snap install --dangerous --devmode linux-steam-integration*.snap
```

### Running

```bash
snap run linux-steam-integration
```

### Run with debug

This will drop you to a shell within the runtime and allow you to execute
LSI's Steam shim with debugging enabled.

```bash
snap run --shell linux-steam-integration
$ export LSI_DEBUG=1
$ $SNAP/linux-steam-integration
```

## Known Issues

Tracking some currently known shortcomings here:

 - No udev roles exposed to host. Talking with upstream to improve this in a new snapd interface
 - No testing yet done outside Solus! Need to test biarch + multiarch distros with NVIDIA & open source drivers.
 - "Home" for Steam is within the snap root. Removing snap will uninstall those local games
 - Requires `--devmode` install as confinement isn't yet finished.
 - `LSI_DEBUG` will cause crashes on Ubuntu (potentially stack size issue?)

## License

Copyright © 2017 Solus Project

runtime-snaps is available under the terms of the `GPL-2.0` license.

The distributed binary snap will fall under multiple licenses, consult
the included packages to determine licensing details for the entire binary
image.

`* Some names may be claimed as the property of others.`
