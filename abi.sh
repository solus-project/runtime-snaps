#!/bin/bash
set -e
set -x

pushd abi
unsquashfs ../solus-runtime-gaming*.snap
abireport scan-tree squashfs-root -p abi_
