runtime-snaps
=============

WIP: Staging area to begin building the Solus Gaming Runtime and port
[Linux Steam* Integration](https://github.com/solus-project/linux-steam-integration) to [Snaps](https://snapcraft.io/)

We are not currently planning on making an SDK available, as the runtime will
primarily be derived from the Solus repositories, with minor layering happening
within the local runtimes.

As and when we have the core components in place we can start discussions around
SDK + debugging availability.

For now, this repository is public should people wish to watch the progress, note
that there is nothing usable just yet.

### Planned Usage

Runtimes:

 - `solus-runtime-gaming`

Applications:

 - `linux-steam-integration` + `steam` (single snap)

Note that for now we'll not be focusing on strict confinement, so the snaps
should be installed with `--devmode` until such point as proper confinement
is feasible.

runtime-snaps is a [Solus project](https://solus-project.com/)

![logo](https://build.solus-project.com/logo.png)

How to build and run
====================

You must be on Solus to **build** these snaps. You will also require a minimum
snapd version of `2.29.2` with the following patches applied:

 - https://github.com/snapcore/snapd/commit/ec4f3c0774620dd2bb6df765b337fa8a67d2afc8 ([patch](https://github.com/snapcore/snapd/commit/ec4f3c0774620dd2bb6df765b337fa8a67d2afc8.patch))
 - https://github.com/snapcore/snapd/pull/4199 ([patch](https://patch-diff.githubusercontent.com/raw/snapcore/snapd/pull/4199.patch))

After installing the relevant snapd, ensure your apparmor rules are applied and snapd has been
restarted. Be lazy, reboot. People do it.

### Build solus-runtime-gaming

```bash
sudo ./round1.sh
````

### Build linux-steam-integration

```bash
sudo ./mkapp.sh
```

### Installation

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
$ $SNAP/usr/bin/linux-steam-integration
```


## License

Copyright © 2017 Solus Project

runtime-snaps is available under the terms of the `GPL-2.0` license.

The distributed binary snap will fall under multiple licenses, consult
the included packages to determine licensing details for the entire binary
image.

`* Some names may be claimed as the property of others.`
