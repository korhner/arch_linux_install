#!/usr/bin/env bash

set -e

echo "Installing the base system"
pacstrap /mnt base linux "$MICROCODE" linux-firmware

#uncomment this if on virtualbox
#echo "Installing vm guest utils"
#pacstrap /mnt virtualbox-guest-utils
#systemctl enable vboxservice --root=/mnt &>/dev/null

echo "Setting up base system"
pacstrap /mnt base-devel mkinitcpio networkmanager dhcpcd btrfs-progs
arch-chroot /mnt systemctl enable NetworkManager

echo "Configure initramfs"
sed -i '/^HOOKS/ c HOOKS=(base udev autodetect consolefont keymap modconf keyboard block encrypt filesystems fsck)' /mnt/etc/mkinitcpio.conf
sed -i '/^MODULES/ c MODULES=($MKINITCPIO_MODULES)' /mnt/etc/mkinitcpio.conf
arch-chroot /mnt mkinitcpio -p linux

echo "Setup standard settings"
echo "$LOCALE.UTF-8 UTF-8" >> /mnt/etc/locale.gen
echo "LANG=$LOCALE.UTF-8" > /mnt/etc/locale.conf
arch-chroot /mnt locale-gen
arch-chroot /mnt ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
echo "127.0.0.1    $HOST_NAME.localdomain  $HOST_NAME" >> /mnt/etc/hosts
arch-chroot /mnt timedatectl set-ntp 1
arch-chroot /mnt hwclock --systohc

echo "Create user"
arch-chroot /mnt useradd --create-home -G wheel "$USER_NAME"
echo "$USER_NAME ALL=(ALL) ALL" >> /mnt/etc/sudoers.d/"$USER_NAME"
echo "$USER_NAME:$USER_PASSWORD" | arch-chroot /mnt chpasswd

echo "Getting an ip address"
arch-chroot /mnt dhcpcd
