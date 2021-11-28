#!/usr/bin/env bash

set -e

# REQUIREMENTS:
# - connect to internet (either cable or run `iwctl` for wifi. more on https://wiki.archlinux.org/title/Iwd#iwctl)

if [ -z "$FILESYSTEM" ]
then
  echo "Insert filesystem. Supported values: $(ls filesystem)"
  read FILESYSTEM
  export FILESYSTEM
fi

if [ -z "$BOOT_LOADER" ]
then
  echo "Insert boot loader. Supported values: $(ls bootloader)"
  read BOOT_LOADER
  export BOOT_LOADER
fi

if [ -z "$DESKTOP" ]
then
  echo "Insert desktop. Supported values: $(ls desktop)"
  read DESKTOP
  export DESKTOP
fi

./filesystem/"$FILESYSTEM"/partition.sh
./filesystem/"$FILESYSTEM"/mount.sh
./base/base.sh
./bootloader/"$BOOT_LOADER"/install.sh
./bootloader/"$BOOT_LOADER"/configure_"$FILESYSTEM".sh
./desktop/"$DESKTOP"/install.sh

if [ -z "$ADDITIONAL_PACKAGES" ]
then
  echo "Installing additional packages"
  pacstrap /mnt "$ADDITIONAL_PACKAGES"
fi

echo "Installation successful, now reboot"
