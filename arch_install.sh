#!/usr/bin/env -S bash -e

# REQUIREMENTS:
# - connect to internet (either cable or run `iwctl` for wifi. more on https://wiki.archlinux.org/title/Iwd#iwctl)

source ./utils.sh
source ./input.sh

./partition_${FILESYSTEM}.sh
./mount_${FILESYSTEM}.sh
./base_linux.sh
./boot_${BOOT}.sh
./desktop_{$DESKTOP}.sh

print "Installation successful, now reboot"
