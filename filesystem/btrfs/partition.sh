#!/usr/bin/env bash

set -e

echo "Wiping $DISK_NAME."
wipefs -af "$DISK_NAME"
sgdisk -Zo "$DISK_NAME"

echo "Create efi, cryptswap and cryptsystem partitions"
sgdisk --clear \
       --new=1:0:+550Mib --typecode=1:ef00 --change-name=1:EFI \
       --new=2:0:+$SWAP_PARTITION_SIZE --typecode=2:8200 --change-name=2:cryptswap \
       --new=3:0:0       --typecode=3:8200 --change-name=3:cryptsystem \
         $DISK_NAME

echo "Sleeping to give os a chance to update partitions"
sleep 5

echo "Format EFI partition"
mkfs.fat -F32 -n EFI /dev/disk/by-partlabel/EFI

echo "Encrypt cryptsystem partition"
echo -n "$DISK_PASSWORD" | cryptsetup luksFormat --align-payload=8192 -s 256 -c aes-xts-plain64 /dev/disk/by-partlabel/cryptsystem -d -

echo "Encrypt swap"
mkfs.ext2 -L cryptswap /dev/disk/by-partlabel/cryptswap 1M

$(dirname "$0")/decrypt.sh

echo "Create and enable swap"
mkswap -L swap /dev/mapper/swap
swapon -L swap

echo "Create BTRFS top subvolume"
mkfs.btrfs --force --label system /dev/mapper/system

echo "Mount top level subvolume"
mount -t btrfs LABEL=system /mnt

echo "Create subvolumes"
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots

echo "Mount subvolumes"
umount -R /mnt

echo "Generate fstab"
genfstab -L /mnt >> /mnt/etc/fstab

echo "Swap will not have a LABEL on boot, so we replace that with the mapper path to swap"
sed -i "s#LABEL=swap#/dev/mapper/swap#" /mnt/etc/fstab

echo "Add swap to /mnt/etc/crypttab"
echo 'swap     LABEL=cryptswap  /dev/urandom  swap,offset=1024,cipher=aes-xts-plain64,size=512' >> /mnt/etc/crypttab