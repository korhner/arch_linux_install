#!/usr/bin/env bash

set -e

source ./utils.sh

pretty_print "Install KDE"
pacstrap /mnt plasma sddm
arch-chroot /mnt systemctl enable sddm
