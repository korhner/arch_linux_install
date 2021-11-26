#!/usr/bin/env bash

o=defaults,x-mount.mkdir
o_btrfs=$o,compress=lzo,ssd,noatime
mount -t btrfs -o subvol=@,$o_btrfs LABEL=system /mnt
mount -t btrfs -o subvol=@home,$o_btrfs LABEL=system /mnt/home
mount -t btrfs -o subvol=@snapshots,$o_btrfs LABEL=system /mnt/.snapshots
mount -o $o LABEL=EFI /mnt/boot
