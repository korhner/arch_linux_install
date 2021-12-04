#!/usr/bin/env bash

set -e

mount -t btrfs -o subvol=@,defaults,compress=lzo,relatimeX-mount.mkdir LABEL=system /mnt
mount -t btrfs -o subvol=@home,defaults,compress=lzo,relatimeX-mount.mkdir LABEL=system /mnt/home
mount -t btrfs -o subvol=@snapshots,defaults,compress=lzo,relatime,X-mount.mkdir LABEL=system /mnt/.snapshots
mount -o defaults,X-mount.mkdir LABEL=EFI /mnt/boot

