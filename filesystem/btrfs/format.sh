#!/usr/bin/env bash

set -e

echo "Create BTRFS top subvolume"
mkfs.btrfs --force --label system /dev/rootvg/system

echo "Mount top level subvolume"
mount -t btrfs LABEL=system /mnt

echo "Create subvolumes"
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots

umount -R /mnt