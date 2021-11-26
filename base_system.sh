#!/usr/bin/env bash

set -e

source ./utils.sh
source ./input.sh

pretty_print "Setup standard settings"
echo "en_US.UTF-8 UTF-8" >> /mnt/etc/locale.gen
echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf
arch-chroot /mnt locale-gen
arch-chroot /mnt ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
echo "127.0.0.1    $HOSTNAME.localdomain  $HOSTNAME" >> /mnt/etc/hosts
arch-chroot /mnt timedatectl set-ntp 1
arch-chroot /mnt hwclock --systohc

pretty_print "Create user"
arch-chroot /mnt useradd --create-home -G wheel "$USER"
echo "$USER ALL=(ALL) ALL" >> /etc/sudoers.d/"$USER"
echo "$USER:$PASSWORD" | arch-chroot /mnt chpasswd

pretty_print "Getting an ip address"
arch-chroot /mnt dhcpcd
