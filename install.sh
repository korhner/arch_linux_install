#!/usr/bin/env bash

set -e

# REQUIREMENTS:
# - connect to internet (either cable or run `iwctl` for wifi. more on https://wiki.archlinux.org/title/Iwd#iwctl)

source ./filesystem/input.sh
source ./filesystem/"$FILESYSTEM"/input.sh
./filesystem/"$FILESYSTEM"/install.sh

source ./base/input.sh
./base/install.sh

source ./bootloader/input.sh
source ./bootloader/"$BOOT_LOADER"/input.sh
./bootloader/"$BOOT_LOADER"/install.sh

source ./desktop/input.sh
source ./desktop/"$DESKTOP"/input.sh
./desktop/"$DESKTOP"/install.sh

if [ -z "$ADDITIONAL_PACKAGES" ]
then
  echo "Installing additional packages"
  pacstrap /mnt "$ADDITIONAL_PACKAGES"
fi

hypervisor=$(systemd-detect-virt)
if [ "$hypervisor" == "oracle" ]
then
  print "VirtualBox has been detected."
  print "Installing guest tools."
  pacstrap /mnt virtualbox-guest-utils
  print "Enabling specific services for the guest tools."
  systemctl enable vboxservice --root=/mnt
fi

echo "Installation successful, now reboot"
