#!/usr/bin/env bash

set -e

# REQUIREMENTS:
# - connect to internet (either cable or run `iwctl` for wifi. more on https://wiki.archlinux.org/title/Iwd#iwctl)

BOOT_PARTITION_NAME=EFI
CRYPTED_PARTITION_NAME=cryptsystem
DECRYPTED_PARTITION_NAME=system

echo ""
echo -e "\e[1m\e[36mEnter disk password (you will not see it):\e[0m"
read -s disk_password

echo -n "$disk_password" | cryptsetup open /dev/disk/by-partlabel/"$CRYPTED_PARTITION_NAME" "$DECRYPTED_PARTITION_NAME" -d -

mount -o defaults,X-mount.mkdir LABEL="$BOOT_PARTITION_NAME" /mnt/boot
mount -o subvol=@,defaults,compress=lzo,X-mount.mkdir LABEL="$DECRYPTED_PARTITION_NAME" /mnt
mount -o subvol=@home,defaults,compress=lzo,X-mount.mkdir LABEL="$DECRYPTED_PARTITION_NAME" /mnt/home
mount -o subvol=@snapshots,defaults,compress=lzo,X-mount.mkdir LABEL="$DECRYPTED_PARTITION_NAME" /mnt/.snapshots
mount -o subvol=@swap,X-mount.mkdir LABEL="$DECRYPTED_PARTITION_NAME" /mnt/swap


