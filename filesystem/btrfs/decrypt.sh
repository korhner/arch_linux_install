#!/usr/bin/env bash

set -e

echo -n "$DISK_PASSWORD" | cryptsetup open /dev/disk/by-partlabel/cryptsystem system -d -
cryptsetup open /dev/disk/by-label/cryptswap swap --key-file=/dev/urandom --offset=1024 --type=plain --cipher=aes-xts-plain64:sha256
