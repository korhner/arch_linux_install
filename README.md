# arch_linux_install
Scripts for my personal use for automatic installation of Arch Linux

## Instructions

- Create a bootable USB flash by following this guide: https://archlinux.org/ (you might also need to disable secure boot in BIOS)
- Boot from USB
- Install git by running `pacman -Sy git`
- Clone this repo by running `git clone https://github.com/korhner/arch_linux_install`
- `cd arch_linux_install`
- `./install.sh`

## Booting into an installed system

Sometimes, due to broken install or inability to boot the system, the only way to access filesystem and repair errors is by booting from live ISO image. To do so, boot as if installing a new system, but instead of running `install.sh`, run `mount_fs_from_live_image.sh`. This command will attempt to mount existing file system and provide a way to access it and fix the errors.