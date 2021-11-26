#!/usr/bin/env bash

set -e

########################################################################################################################
# Interactive variables. To avoid asking for user input, add `export VARIABLE=<value>` before if condition
########################################################################################################################

if [ -z "$DISK_NAME" ]
then
  lsblk -p
  echo "Enter full disk path for installation. Check output of lsblk above. For example /dev/sda or /dev/nvme0n1"
  echo "Selected disk will be wiped and formatted!"
  read DISK_NAME
  export DISK_NAME
fi

if [ -z "$PASSWORD" ]
then
  echo "Insert password for LUKS disk encryption and user (you will not see it)"
  read -s PASSWORD
  export PASSWORD
fi

if [ -z "$SWAP_PARTITION_SIZE" ]
then
  cat << EOF
Enter size of swap partition. Format is given below, for example 2Gib
Below table of recommendation is output of `free -h`
Hibernation is not supported in this install script, so pick first column as recommendation
https://itsfoss.com/swap-size/
RAM Size    Swap Size (Without Hibernation)
256Mib       256Mib
512Mib       512Mib
1Gib         1Gib
2Gib         1Gib
3Gib         2Gib
4Gib         2Gib
6Gib         2Gib
8Gib         3Gib
12Gib        3Gib
16Gib        4Gib
24Gib        5Gib
32Gib        6Gib
64Gib        8Gib
128Gib       11Gib
EOF
  free -h
  read SWAP_PARTITION_SIZE
  export SWAP_PARTITION_SIZE
fi

if [ -z "$MICROCODE" ]
then
  grep 'model name' /proc/cpuinfo
  echo "Enter microcode package. For intel cpus enter intel-ucode, for amd am-ucode. Check output of /proc/cpuinfo above"
  echo "Check https://wiki.archlinux.org/title/microcode for more details"
  read MICROCODE
  export MICROCODE
fi

if [ -z "$USER" ]
then
  echo "Set name of user"
  read USER
  export USER
fi

if [ -z "$HOSTNAME" ]
then
  echo "Set hostname"
  read HOSTNAME
  export HOSTNAME
fi

########################################################################################################################
# non interactive assumptions
########################################################################################################################
# Space separated mkinitcpio modules. 
# Check arch wiki guide for your system.
# For example, x1 carbon needs i915
export MKINITCPIO_MODULES="usb_storage thunderbolt"

export TIMEZONE="Europe/Belgrade"

########################################################################################################################
# modules of installation. edit those manually if not happy with defaults
########################################################################################################################
# runs partition_$FILESYSTEM.sh and mount_$FILESYSTEM.sh
export FILESYSTEM=btrfs
# runs boot_$BOOT.sh
export BOOT=refind
# runs desktop_$DESKTOP.sh
export DESKTOP=kde

