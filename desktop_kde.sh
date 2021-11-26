#!/usr/bin/env bash

source ./utils.sh

pretty_print "Install KDE"
pacstrap /mnt plasma sddm
arch-chroot /mnt systemctl enable sddm
