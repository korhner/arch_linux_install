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

echo "Mount swap subvolume and create swap file"
mount -t btrfs -o subvol=@swap,X-mount.mkdir LABEL=system /mnt/swap
touch /mnt/swap/swapfile
chmod 600 /mnt/swap/swapfile
chattr +C /mnt/swap/swapfile
dd if=/dev/zero of=/mnt/swap/swapfile bs=1M count="$SWAP_PARTITION_SIZE_MB"
arch-chroot /mnt mkswap /mnt/swap/swapfile
arch-chroot /mnt swapon /mnt/swap/swapfile
#UUID=XXXXXXXXXXXXXXX /swap btrfs subvol=@swap 0 0
#/swap/swapfile none swap sw 0 0