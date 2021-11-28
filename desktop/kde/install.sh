#!/usr/bin/env bash

set -e

echo "Install KDE"
pacstrap /mnt plasma sddm
arch-chroot /mnt systemctl enable sddm
