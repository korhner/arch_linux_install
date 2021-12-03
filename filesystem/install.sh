#!/usr/bin/env bash

set -e

# Disk is formatted with 2 partitions, EFI and LVM partition.
# LVM partition is encrypted with LUKS, and has 2 logical volumes: system and swap
# system partition filesystem is extensible via $FILESYSTEM variable
# extension filesystem needs the following entry points:
#  - input.sh (ask user for variables)
#  - format.sh (format /dev/mapper/system partition)
#  - mount.sh (mount formatted filesystem)

echo "Wiping $DISK_NAME."
wipefs -af "$DISK_NAME"
sgdisk -Zo "$DISK_NAME"

echo "Create efi, cryptswap and cryptsystem partitions"
sgdisk --clear \
       --new=1:0:+550Mib --typecode=1:ef00 --change-name=1:EFI \
       --new=2:0:0       --typecode=1:8309 --change-name=2:cryptlvm \
         $DISK_NAME

echo "Sleeping to give os a chance to update partitions"
sleep 5

echo "Format EFI partition"
mkfs.fat -F32 -n EFI /dev/disk/by-partlabel/EFI

echo "Encrypt cryptsystem partition"
echo -n "$DISK_PASSWORD" | cryptsetup luksFormat /dev/disk/by-partlabel/cryptlvm -d -
echo -n "$DISK_PASSWORD" | cryptsetup open /dev/disk/by-partlabel/cryptlvm cryptlvm -d -

echo "Create logical volumes"
pvcreate /dev/mapper/cryptlvm
vgcreate rootvg /dev/mapper/cryptlvm
lvcreate -L "$SWAP_PARTITION_SIZE" rootvg -n swap
lvcreate -l 100%FREE rootvg -n system

echo "Create and enable swap"
mkswap -L swap /dev/rootvg/swap
swapon -L swap

echo "Format system filesystem"
$(dirname "$0")/$FILESYSTEM/format.sh
$(dirname "$0")/mount.sh

echo "Generate fstab"
mkdir -p /mnt/etc
genfstab -L /mnt >> /mnt/etc/fstab