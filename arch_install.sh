#!/usr/bin/env -S bash -e

# REQUIREMENTS:
# - connect to internet (either cable or run `iwctl` for wifi. more on https://wiki.archlinux.org/title/Iwd#iwctl)

source ./input.sh

print () {
    echo -e "\e[1m\e[93m[ \e[92m•\e[93m ] \e[4m$1\e[0m"
}

print "Wiping $DISK_NAME."
wipefs -af "$DISK_NAME"
sgdisk -Zo "$DISK_NAME"

print "Create efi, cryptswap and cryptsystem partitions"
sgdisk --clear \
       --new=1:0:+550Mib --typecode=1:ef00 --change-name=1:EFI \
       --new=2:0:+$SWAP_PARTITION_SIZE --typecode=2:8200 --change-name=2:cryptswap \
       --new=3:0:0       --typecode=3:8200 --change-name=3:cryptsystem \
         $DISK_NAME

print "Sleeping to give os a chance to update partitions"
sleep 5

print "Format EFI partition"
mkfs.fat -F32 -n EFI /dev/disk/by-partlabel/EFI

print "Encrypt cryptsystem partition"
echo -n "$PASSWORD" | cryptsetup luksFormat --align-payload=8192 -s 256 -c aes-xts-plain64 /dev/disk/by-partlabel/cryptsystem -d -

print "Descrypt cryptsystem partition"
echo -n "$PASSWORD" | cryptsetup open /dev/disk/by-partlabel/cryptsystem system -d -

print "Encrypt swap"
mkfs.ext2 -L cryptswap /dev/disk/by-partlabel/cryptswap 1M
cryptsetup open /dev/disk/by-label/cryptswap swap --key-file=/dev/urandom --offset=1024 --type=plain --cipher=aes-xts-plain64:sha256

print "Create and enable swap"
mkswap -L swap /dev/mapper/swap
swapon -L swap

print "Create BTRFS top subvolume"
mkfs.btrfs --force --label system /dev/mapper/system

print "Mount top level subvolume"
mount -t btrfs LABEL=system /mnt

print "Create subvolumes"
btrfs subvolume create /mnt/root
btrfs subvolume create /mnt/home
btrfs subvolume create /mnt/snapshots

print "Mount subvolumes"
umount -R /mnt
o=defaults,x-mount.mkdir
o_btrfs=$o,compress=lzo,ssd,noatime
mount -t btrfs -o subvol=root,$o_btrfs LABEL=system /mnt
mount -t btrfs -o subvol=home,$o_btrfs LABEL=system /mnt/home
mount -t btrfs -o subvol=snapshots,$o_btrfs LABEL=system /mnt/.snapshots
mount -o $o LABEL=EFI /mnt/boot

print "Installing the base system"
pacstrap /mnt base linux $MICROCODE linux-firmware


#uncomment this if on virtualbox
#print "Installing vm guest utils"
#pacstrap /mnt virtualbox-guest-utils
#systemctl enable vboxservice --root=/mnt &>/dev/null

print "Generate fstab"
genfstab -L /mnt >> /mnt/etc/fstab

print "Swap will not have a LABEL on boot, so we replace that with the mapper path to swap"
sed -i "s#LABEL=swap#/dev/mapper/swap#" /mnt/etc/fstab

print "Add swap to /mnt/etc/crypttab"
echo 'swap     LABEL=cryptswap  /dev/urandom  swap,offset=1024,cipher=aes-xts-plain64,size=512' >> /mnt/etc/crypttab

print "Setting up base system"
pacstrap /mnt base-devel mkinitcpio networkmanager dhcpcd btrfs-progs iw zsh vim terminus-font wget zip unzip pigz pbzip2 htop nload iftop
arch-chroot /mnt systemctl enable NetworkManager

print "Configure initramfs"
sed -i '/^HOOKS/ c HOOKS=(base udev autodetect consolefont keymap modconf keyboard block encrypt filesystems fsck)' /mnt/etc/mkinitcpio.conf
sed -i '/^MODULES/ c MODULES=($MKINITCPIO_MUDOLES)' /mnt/etc/mkinitcpio.conf
arch-chroot /mnt mkinitcpio -p linux

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

print "Setup standard settings"
echo "en_US.UTF-8 UTF-8" >> /mnt/etc/locale.gen
echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf
arch-chroot /mnt locale-gen
arch-chroot /mnt ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime
echo "127.0.0.1    $HOSTNAME.localdomain  $HOSTNAME" >> /mnt/etc/hosts
arch-chroot /mnt timedatectl set-ntp 1
arch-chroot /mnt hwclock --systohc

print "Create user"
arch-chroot /mnt useradd --create-home -G wheel "$USER"
echo "$USER ALL=(ALL) ALL" >> /etc/sudoers.d/"$USER"
echo "$USER:$PASSWORD" | arch-chroot /mnt chpasswd

print "Getting an ip address"
arch-chroot /mnt dhcpcd

print "Install KDE"
pacstrap /mnt plasma sddm
arch-chroot /mnt systemctl enable sddm

print "Installation successful, now reboot"
