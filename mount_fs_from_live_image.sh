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

if [ -z "$DISK_PASSWORD" ]
then
  echo "Insert password for LUKS disk encryption (you will not see it)"
  read -s DISK_PASSWORD
  export DISK_PASSWORD
fi

./filesystem/"$FILESYSTEM"/mount.sh
./filesystem/"$FILESYSTEM"/decrypt.sh

