#!/usr/bin/env bash

set -e

if [ -z "$FILESYSTEM" ]
then
  echo "Insert filesystem. Supported values: $(ls filesystem)"
  read FILESYSTEM
  export FILESYSTEM
fi

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
Below table of recommendation is output of free -h:
$(free -h)

https://itsfoss.com/swap-size/

RAM Size	Swap Size  Swap size (With Hibernation)
4Gib	      2Gib	   6Gib
6Gib	      2Gib	   8Gib
8Gib	      3Gib	   11Gib
12Gib	      3Gib	   15Gib
16Gib	      4Gib	   20Gib
24Gib	      5Gib	   29Gib
32Gib	      6Gib	   38Gib
64Gib	      8Gib	   72Gib
128Gib	    11Gib	   9Gib
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