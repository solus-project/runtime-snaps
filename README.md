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

## License

Copyright © 2017 Solus Project

runtime-snaps is available under the terms of the `GPL-2.0` license.

The distributed binary snap will fall under multiple licenses, consult
the included packages to determine licensing details for the entire binary
image.

`* Some names may be claimed as the property of others.`
