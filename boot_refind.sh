#!/usr/bin/env -S bash -e

source ./utils.sh
source ./input.sh

print "Install rEFInd"
pacstrap /mnt refind
arch-chroot /mnt refind-install

print "Configure rEFInd update hook"
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

print "Configure rEFInd boot"
system_uuid=`blkid | grep 'LABEL="system"' | sed -r 's/.* UUID="([^"]+)".*/\1/'`
cat <<END >/mnt/boot/refind_linux.conf
"Boot with standard options"  "root=UUID=$system_uuid rw rootflags=subvol=root cryptdevice=PARTLABEL=cryptsystem:system cryptkey=PARTLABEL=decrypt:10240:256 quiet initrd=$MICROCODE.img initrd=initramfs-%v.img"
"Boot to single-user mode"    "root=UUID=$system_uuid rw rootflags=subvol=root cryptdevice=PARTLABEL=cryptsystem:system cryptkey=PARTLABEL=decrypt:10240:256 quiet single"
"Boot with minimal options"   "ro root=/dev/mapper/system"
END
