#!/usr/bin/env bash

set -e

# Disk is formatted with 2 partitions, EFI and encrypted LUKS partition.
# LUKS partition filesystem is extensible via $FILESYSTEM variable
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
       --new=2:0:0       --typecode=1:8309 --change-name=2:cryptsystem \
         $DISK_NAME

echo "Sleeping to give os a chance to update partitions"
sleep 5

echo "Format EFI partition"
mkfs.fat -F32 -n EFI /dev/disk/by-partlabel/EFI

echo "Encrypt cryptsystem partition"
echo -n "$DISK_PASSWORD" | cryptsetup luksFormat /dev/disk/by-partlabel/cryptsystem -d -
echo -n "$DISK_PASSWORD" | cryptsetup open /dev/disk/by-partlabel/cryptsystem system -d -


echo "Setup main filesystem"
$(dirname "$0")/$FILESYSTEM/format.sh
$(dirname "$0")/$FILESYSTEM/mount.sh

echo "Generate fstab"
mkdir -p /mnt/etc
genfstab -L /mnt >> /mnt/etc/fstab