#!/usr/bin/env bash

source ./utils.sh
source ./input.sh

pretty_print "Wiping $DISK_NAME."
wipefs -af "$DISK_NAME"
sgdisk -Zo "$DISK_NAME"

pretty_print "Create efi, cryptswap and cryptsystem partitions"
sgdisk --clear \
       --new=1:0:+550Mib --typecode=1:ef00 --change-name=1:EFI \
       --new=2:0:+$SWAP_PARTITION_SIZE --typecode=2:8200 --change-name=2:cryptswap \
       --new=3:0:0       --typecode=3:8200 --change-name=3:cryptsystem \
         $DISK_NAME

pretty_print "Sleeping to give os a chance to update partitions"
sleep 5

pretty_print "Format EFI partition"
mkfs.fat -F32 -n EFI /dev/disk/by-partlabel/EFI

pretty_print "Encrypt cryptsystem partition"
echo -n "$PASSWORD" | cryptsetup luksFormat --align-payload=8192 -s 256 -c aes-xts-plain64 /dev/disk/by-partlabel/cryptsystem -d -

pretty_print "Encrypt swap"
mkfs.ext2 -L cryptswap /dev/disk/by-partlabel/cryptswap 1M

./decrypt.sh

pretty_print "Create and enable swap"
mkswap -L swap /dev/mapper/swap
swapon -L swap

pretty_print "Create BTRFS top subvolume"
mkfs.btrfs --force --label system /dev/mapper/system

pretty_print "Mount top level subvolume"
mount -t btrfs LABEL=system /mnt

pretty_print "Create subvolumes"
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/snapshots

pretty_print "Mount subvolumes"
umount -R /mnt
