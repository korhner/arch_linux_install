#!/usr/bin/env bash

set -e

echo "Configure rEFInd boot"
system_uuid=`sudo blkid | grep 'LABEL="system"' | sed -r 's/.* UUID="([^"]+)".*/\1/'`
cat <<END >/mnt/boot/EFI/refind/refind.conf
timeout 3

# When set to 1 or above, rEFInd creates a file called refind.log in
# its home directory on the ESP and records information about what it's
# doing. Higher values record more information, up to a maximum of 4.
# This token should be left at the default of 0 except when debugging
# problems.
log_level 0

use_nvram false
menuentry "Arch Linux" {
    icon     /EFI/refind/icons/os_arch.png
    loader   /vmlinuz-linux
    options  "root=UUID=$system_uuid rw rootflags=subvol=@ cryptdevice=PARTLABEL=cryptsystem:system cryptkey=PARTLABEL=decrypt:10240:256 quiet initrd=\\$MICROCODE.img initrd=\initramfs-linux.img"

    submenuentry "Boot using fallback initramfs" {
        options  "root=UUID=$system_uuid rw rootflags=subvol=@ cryptdevice=PARTLABEL=cryptsystem:system cryptkey=PARTLABEL=decrypt:10240:256 quiet initrd=\\$MICROCODE.img initrd=\initramfs-linux-fallback.img"
    }

    submenuentry "Boot to terminal" {
        add_options "systemd.unit=multi-user.target"
    }

    submenuentry "Boot to single user mode" {
        add_options "single"
    }
}
END
