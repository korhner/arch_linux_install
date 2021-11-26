#!/usr/bin/env bash

set -e

if [ -z "$PASSWORD" ]
then
  echo "Insert password for LUKS disk encryption (you will not see it)"
  read -s PASSWORD
  export PASSWORD
fi

echo -n "$PASSWORD" | cryptsetup open /dev/disk/by-partlabel/cryptsystem system -d -
cryptsetup open /dev/disk/by-label/cryptswap swap --key-file=/dev/urandom --offset=1024 --type=plain --cipher=aes-xts-plain64:sha256
