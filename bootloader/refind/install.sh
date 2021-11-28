#!/usr/bin/env bash

set -e

echo "Install rEFInd"
pacstrap /mnt refind
arch-chroot /mnt refind-install
rm -f /mnt/boot/refind_linux.conf  # we will configure using /boot/EFI/refind/refind.conf

echo "Configure rEFInd update hook"
mkdir -p /mnt/etc/pacman.d/hooks
cat > /mnt/etc/pacman.d/hooks/refind.hook <<EOF
[Trigger]
Operation=Upgrade
Type=Package
Target=refind

[Action]
Description = Updating rEFInd on ESP
When=PostTransaction
Exec=/usr/bin/refind-install
EOF