#!/usr/bin/env -S bash -e

source ./utils.sh

print "Install KDE"
pacstrap /mnt plasma sddm
arch-chroot /mnt systemctl enable sddm
