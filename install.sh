#!/usr/bin/env bash

set -e

# REQUIREMENTS:
# - connect to internet (either cable or run `iwctl` for wifi. more on https://wiki.archlinux.org/title/Iwd#iwctl)

source ./filesystem/input.sh
source ./filesystem/"$FILESYSTEM"/input.sh

source ./base/input.sh

source ./bootloader/input.sh
source ./bootloader/"$BOOT_LOADER"/input.sh

source ./desktop/input.sh
source ./desktop/"$DESKTOP"/input.sh

./filesystem/install.sh
./base/install.sh
./filesystem/"$FILESYSTEM"/swap.sh
./bootloader/"$BOOT_LOADER"/install.sh
./desktop/"$DESKTOP"/install.sh

if [ -z "$ADDITIONAL_PACKAGES" ]
then
  echo "Installing additional packages"
  pacstrap /mnt "$ADDITIONAL_PACKAGES"
fi

echo "Installation successful, now reboot"
