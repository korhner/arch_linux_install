echo "Mount swap subvolume and create swap file"
mount -t btrfs -o subvol=@swap,X-mount.mkdir LABEL=system /mnt/swap
touch /mnt/swap/swapfile
chmod 600 /mnt/swap/swapfile
chattr +C /mnt/swap/swapfile
dd if=/dev/zero of=/mnt/swap/swapfile bs=1M count="$SWAP_PARTITION_SIZE_MB"

arch-chroot /mnt mkswap /swap/swapfile
arch-chroot /mnt swapon /swap/swapfile