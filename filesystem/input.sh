#!/usr/bin/env bash

set -e

if [ -z "$DISK_NAME" ]
then
  lsblk -p
  echo "Enter full disk path for installation. Check output of lsblk above. For example /dev/sda or /dev/nvme0n1"
  echo "Selected disk will be wiped and formatted!"
  read DISK_NAME
  export DISK_NAME
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

if [ -z "$DISK_PASSWORD" ]
then
  echo "Insert password for LUKS disk encryption (you will not see it)"
  read -s DISK_PASSWORD
  export DISK_PASSWORD
fi