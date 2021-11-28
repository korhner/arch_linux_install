#!/usr/bin/env bash

set -e

# REQUIREMENTS:
# - connect to internet (either cable or run `iwctl` for wifi. more on https://wiki.archlinux.org/title/Iwd#iwctl)

source ./filesystem/input.sh
source ./filesystem/"$FILESYSTEM"/input.sh
./filesystem/"$FILESYSTEM"/partition.sh
./filesystem/"$FILESYSTEM"/mount.sh

source ./base/input.sh
./base/base.sh

source ./bootloader/input.sh
source ./bootloader/"$BOOT_LOADER"/input.sh
./bootloader/"$BOOT_LOADER"/install.sh
./bootloader/"$BOOT_LOADER"/configure_"$FILESYSTEM".sh

source ./desktop/input.sh
source ./desktop/"$DESKTOP"/input.sh
./desktop/"$DESKTOP"/install.sh

if [ -z "$ADDITIONAL_PACKAGES" ]
then
  echo "Installing additional packages"
  pacstrap /mnt "$ADDITIONAL_PACKAGES"
fi

echo "Installation successful, now reboot"