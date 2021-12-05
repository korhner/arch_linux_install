#!/usr/bin/env bash

set -e

BOOT_PARTITION_NAME=ESP
CRYPTED_PARTITION_NAME=cryptsystem
DECRYPTED_PARTITION_NAME=system

echo "#################################################################################################################"
echo "Collect user input"
echo "#################################################################################################################"

echo ""
echo "Output of 'lsblk -p':"
lsblk -p
echo "Check output of lsblk above to help you select disk where you want to install Arch Linux."
echo "For example /dev/sda or /dev/nvme0n1"
echo "Selected disk will be wiped and formatted!"
echo ""
echo -e "\e[1m\e[36mEnter full disk name:\e[0m"
read disk_name

echo ""
echo "Output of 'free -h':"
free -h
cat << EOF
Recommendations based on https://itsfoss.com/swap-size/
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
echo ""
echo -e "\e[1m\e[36mEnter size of swapfile in megabytes:\e[0m"
read swap_partition_size_mb

echo ""
echo -e "\e[1m\e[36mEnter password for disk encryption (you will not see it):\e[0m"
read -s disk_password

# TODO could be detected automatically
echo ""
echo "Output of /proc/cpuinfo:"
grep 'vendor_id' /proc/cpuinfo | head -n 1
grep 'model name' /proc/cpuinfo | head -n 1
echo "For intel cpus enter intel-ucode, for amd enter amd-ucode"
echo "Check https://wiki.archlinux.org/title/microcode for more details"
echo ""
echo -e "\e[1m\e[36mEnter microcode package:\e[0m"
read microcode


echo ""
echo -e "\e[1m\e[36mEnter locale (en_US is default):\e[0m"
read locale
locale=${locale:-en_US}


detected_timezone=$(curl -s 'http://ip-api.com/line?fields=timezone')
echo ""
echo -e "\e[1m\e[36mEnter timezone ($detected_timezone is default):\e[0m"
read timezone
timezone=${timezone:-$detected_timezone}

echo ""
echo -e "\e[1m\e[36mEnter name of user:\e[0m"
read user_name

echo ""
echo -e "\e[1m\e[36mEnter user password (you will not see it):\e[0m"
read -s user_password

echo ""
echo -e "\e[1m\e[36mEnter host name:\e[0m"
read host_name

echo "#################################################################################################################"
echo "Wiping and partitioning disk"
echo "#################################################################################################################"
wipefs -af "$disk_name"
sgdisk -Zo "$disk_name"
sgdisk --clear \
       --new=1:0:+550Mib --typecode=1:ef00 --change-name=1:"$BOOT_PARTITION_NAME" \
       --new=2:0:0       --typecode=1:8309 --change-name=2:"$CRYPTED_PARTITION_NAME" \
         $disk_name
wait_seconds=10
until test $((wait_seconds--)) -eq 0 -o -e /dev/disk/by-partlabel/"$BOOT_PARTITION_NAME" ; do sleep 1; done

echo "#################################################################################################################"
echo "Formatting partitions"
echo "#################################################################################################################"
mkfs.fat -F32 -n $BOOT_PARTITION_NAME /dev/disk/by-partlabel/$BOOT_PARTITION_NAME

echo -n "$disk_password" | cryptsetup luksFormat /dev/disk/by-partlabel/$CRYPTED_PARTITION_NAME -d -
echo -n "$disk_password" | cryptsetup open /dev/disk/by-partlabel/$CRYPTED_PARTITION_NAME $DECRYPTED_PARTITION_NAME -d -

mkfs.btrfs --label "$DECRYPTED_PARTITION_NAME" /dev/mapper/"$DECRYPTED_PARTITION_NAME"
mount -t btrfs LABEL="$DECRYPTED_PARTITION_NAME" /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@swap
umount -R /mnt

mount -o defaults,X-mount.mkdir LABEL="$BOOT_PARTITION_NAME" /mnt/boot

mount -o subvol=@,defaults,compress=lzo,X-mount.mkdir LABEL="$DECRYPTED_PARTITION_NAME" /mnt
mount -o subvol=@home,defaults,compress=lzo,X-mount.mkdir LABEL="$DECRYPTED_PARTITION_NAME" /mnt/home
mount -o subvol=@snapshots,defaults,compress=lzo,X-mount.mkdir LABEL="$DECRYPTED_PARTITION_NAME" /mnt/.snapshots
mount -o subvol=@swap,X-mount.mkdir LABEL="$DECRYPTED_PARTITION_NAME" /mnt/swap

touch /mnt/swap/swapfile
chmod 600 /mnt/swap/swapfile
chattr +C /mnt/swap/swapfile
dd if=/dev/zero of=/mnt/swap/swapfile bs=1M count="$swap_partition_size_mb"

echo "#################################################################################################################"
echo "Setup base system"
echo "#################################################################################################################"
pacstrap /mnt base linux "$microcode" linux-firmware base-devel mkinitcpio networkmanager dhcpcd btrfs-progs

arch-chroot /mnt mkswap /swap/swapfile
arch-chroot /mnt swapon /swap/swapfile

mkdir -p /mnt/etc
genfstab -L /mnt >> /mnt/etc/fstab

sed -i '/^HOOKS/ c HOOKS=(base udev autodetect consolefont keymap modconf keyboard block encrypt filesystems fsck)' /mnt/etc/mkinitcpio.conf
sed -i '/^MODULES/ c MODULES=(usb_storage thunderbolt)' /mnt/etc/mkinitcpio.conf
arch-chroot /mnt mkinitcpio -p linux

echo "$locale.UTF-8 UTF-8" >> /mnt/etc/locale.gen
echo "LANG=$locale.UTF-8" > /mnt/etc/locale.conf
arch-chroot /mnt locale-gen
arch-chroot /mnt ln -sf /usr/share/zoneinfo/$timezone /etc/localtime
echo "127.0.0.1    $host_name.localdomain  $host_name" >> /mnt/etc/hosts
arch-chroot /mnt timedatectl set-ntp 1
arch-chroot /mnt hwclock --systohc
arch-chroot /mnt useradd --create-home -G wheel "$user_name"
echo "$user_name ALL=(ALL) ALL" >> /mnt/etc/sudoers.d/"$user_name"
echo "$user_name:$user_password" | arch-chroot /mnt chpasswd
arch-chroot /mnt dhcpcd
arch-chroot /mnt systemctl enable NetworkManager

echo "#################################################################################################################"
echo "Setup rEFInd"
echo "#################################################################################################################"
pacstrap /mnt gptfdisk refind
arch-chroot /mnt refind-install
rm -f /mnt/boot/refind_linux.conf  # we will configure using /boot/EFI/refind/refind.conf
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
system_uuid=`sudo blkid | grep "LABEL=\"$DECRYPTED_PARTITION_NAME\"" | sed -r 's/.* UUID="([^"]+)".*/\1/'`
base_options="root=UUID=$system_uuid rw rootflags=subvol=@ cryptdevice=PARTLABEL=$CRYPTED_PARTITION_NAME:$DECRYPTED_PARTITION_NAME cryptkey=PARTLABEL=decrypt:10240:256 quiet initrd=\\$microcode.img"
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
    options  "$base_options initrd=\initramfs-linux.img"

    submenuentry "Boot using fallback initramfs" {
        options  "base_options initrd=\initramfs-linux-fallback.img"
    }

    submenuentry "Boot to terminal" {
        add_options "systemd.unit=multi-user.target"
    }

    submenuentry "Boot to single user mode" {
        add_options "single"
    }
}
END

echo "#################################################################################################################"
echo "Setup laptop specific stuff (lenovo thinkpad x1 3rd gen)"
echo "#################################################################################################################"
pacstrap /mnt nvidia

echo "#################################################################################################################"
echo "Setup my preferred starting packages"
echo "#################################################################################################################"
# desktop
pacstrap /mnt plasma sddm konsole yakuake spectacle dolphin okular kate
arch-chroot /mnt systemctl enable sddm

# various cli tools
zsh vim zsh zip unzip htop nload iftop git bind-tools

