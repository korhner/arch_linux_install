#!/usr/bin/env bash

set -e

mount --mkdir -t btrfs -o subvol=@,defaults,compress=lzo,relatime LABEL=system /mnt
mount --mkdir -t btrfs -o subvol=@home,defaults,compress=lzo,relatime LABEL=system /mnt/home
mount --mkdir -t btrfs -o subvol=@snapshots,defaults,compress=lzo,relatime LABEL=system /mnt/.snapshots
mount --mkdir -o defaults LABEL=EFI /mnt/boot

