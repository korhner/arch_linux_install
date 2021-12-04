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

if [ -z "$SWAP_PARTITION_SIZE_MB" ]
then
  cat << EOF
Enter size of swap partition in megabytes, for example 4096 for 4GB.
Below table of recommendation is output of free -h:
$(free -h)

https://itsfoss.com/swap-size/

RAM Size	Swap Size
4Gib	      2Gib (enter 2048)
6Gib	      2Gib (enter 2048)
8Gib	      3Gib (enter 3072)
12Gib	      3Gib (enter 3072)
16Gib	      4Gib (enter 4096)
24Gib	      5Gib (enter 5120)
32Gib	      6Gib (enter 6144)
64Gib	      8Gib (enter 8192)
128Gib	    11Gib (enter 11264)
EOF
  free -h
  read SWAP_PARTITION_SIZE_MB
  export SWAP_PARTITION_SIZE_MB
fi

if [ -z "$DISK_PASSWORD" ]
then
  echo "Insert password for LUKS disk encryption (you will not see it)"
  read -s DISK_PASSWORD
  export DISK_PASSWORD
fi