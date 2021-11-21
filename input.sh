#!/usr/bin/env -S bash -e

source ./utils.sh

# export PASSWORD=
read_var_if_not_defined_sensitive "Insert password for LUKS and user" PASSWORD

echo $(lsblk -dp)
# export DISK_NAME=
read_var_if_not_defined "Set full disk name. Check output of lsblk above. For example /dev/sda or /dev/nvme0n1" DISK_NAME

cat << EOF
Hibernation is not supported in this install script, so pick first column as recommendation
https://itsfoss.com/swap-size/
RAM Size    Swap Size (Without Hibernation)
256Mib       256Mib
512Mib       512Mib
1Gib         1Gib
2Gib         1Gib
3Gib         2Gib
4Gib         2Gib
6Gib         2Gib
8Gib         3Gib
12Gib        3Gib
16Gib        4Gib
24Gib        5Gib
32Gib        6Gib
64Gib        8Gib
128Gib       11Gib
EOF
# export SWAP_PARTITION_SIZE=
read_var_if_not_defined "Set swap partition size. Hibernation is not supported. Recommended to pick according to guide above" SWAP_PARTITION_SIZE

# https://wiki.archlinux.org/title/microcode
echo $(grep 'model name' /proc/cpuinfo)
# export MICROCODE=
read_var_if_not_defined "Enter microcode package. For intel cpus enter intel-ucode, for amd am-ucode. Check output of /proc/cpuinfo above" MICROCODE


# export USER=
read_var_if_not_defined "Set name of user" USER

# export HOSTNAME=
read_var_if_not_defined "Set hostname" HOSTNAME


# Space separated mkinitcpio modules. 
# Check arch wiki guide for your system.
# For example, x1 carbon needs i915
export MKINITCPIO_MUDOLES="usb_storage thunderbolt"

export TIMEZONE="Europe/Belgrade"

# runs partition_$FILESYSTEM.sh and mount_$FILESYSTEM.sh, replace if needed
export FILESYSTEM=btrfs

# runs boot_$BOOT.sh, replace if needed
export BOOT=refind

# runs desktop_$DESKTOP.sh, replace if needed
export DESKTOP=kde

