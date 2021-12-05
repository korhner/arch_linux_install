#!/usr/bin/env bash

set -e

echo "Create BTRFS top subvolume"
mkfs.btrfs --label system /dev/mapper/system

echo "Mount top level subvolume"
mount -t btrfs LABEL=system /mnt

echo "Create subvolumes"
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@swap

umount -R /mnt

$(dirname "$0")/mount.sh