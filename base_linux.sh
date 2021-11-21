#!/usr/bin/env -S bash -e

source ./utils.sh
source ./input.sh

print "Installing the base system"
pacstrap /mnt base linux $MICROCODE linux-firmware

#uncomment this if on virtualbox
#print "Installing vm guest utils"
#pacstrap /mnt virtualbox-guest-utils
#systemctl enable vboxservice --root=/mnt &>/dev/null

print "Generate fstab"
genfstab -L /mnt >> /mnt/etc/fstab

print "Swap will not have a LABEL on boot, so we replace that with the mapper path to swap"
sed -i "s#LABEL=swap#/dev/mapper/swap#" /mnt/etc/fstab

print "Add swap to /mnt/etc/crypttab"
echo 'swap     LABEL=cryptswap  /dev/urandom  swap,offset=1024,cipher=aes-xts-plain64,size=512' >> /mnt/etc/crypttab

print "Setting up base system"
pacstrap /mnt base-devel mkinitcpio networkmanager dhcpcd btrfs-progs iw zsh vim terminus-font wget zip unzip pigz pbzip2 htop nload iftop
arch-chroot /mnt systemctl enable NetworkManager

print "Configure initramfs"
sed -i '/^HOOKS/ c HOOKS=(base udev autodetect consolefont keymap modconf keyboard block encrypt filesystems fsck)' /mnt/etc/mkinitcpio.conf
sed -i '/^MODULES/ c MODULES=($MKINITCPIO_MUDOLES)' /mnt/etc/mkinitcpio.conf
arch-chroot /mnt mkinitcpio -p linux
