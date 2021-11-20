#!/usr/bin/env -S bash -e

# run `lsblk -dp` and set $DISK_NAME variable to full disk name you want to install arch on (for example /dev/sda)
export DISK_NAME=

# Hibernation is not supported in this install script, so pick first column as recommendation
# https://itsfoss.com/swap-size/
# RAM Size    Swap Size (Without Hibernation)     Swap size (With Hibernation)
# 256Mib       256Mib                               512Mib
# 512Mib       512Mib                               1Gib
# 1Gib         1Gib                                 2Gib
# 2Gib         1Gib                                 3Gib
# 3Gib         2Gib                                 5Gib
# 4Gib         2Gib                                 6Gib
# 6Gib         2Gib                                 8Gib
# 8Gib         3Gib                                 11Gib
# 12Gib        3Gib                                 15Gib
# 16Gib        4Gib                                 20Gib
# 24Gib        5Gib                                 29Gib
# 32Gib        6Gib                                 38Gib
# 64Gib        8Gib                                 72Gib
# 128Gib       11Gib                                139Gib
# format examples: 512Mib, 4Gib
export SWAP_PARTITION_SIZE=

# For inter enter `intel-ucode`, for amd `amd-ucode`
# If you are not sure, check with `grep 'model name' /proc/cpuinfo`
# https://wiki.archlinux.org/title/microcode
export MICROCODE=

export USER=
export HOSTNAME=

# Space separated mkinitcpio modules. 
# Check arch wiki guide for your system.
# For example, x1 carbon needs i915
export MKINITCPIO_MUDOLES="usb_storage thunderbolt"

export TIMEZONE="Europe/Belgrade"

read -r -s -p "Insert password for LUKS and user (you are not going to see the password):" PASSWORD
export PASSWORD
