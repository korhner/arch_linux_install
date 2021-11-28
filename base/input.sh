#!/usr/bin/env bash

set -e

if [ -z "$MICROCODE" ]
then
  grep 'model name' /proc/cpuinfo
  echo "Enter microcode package. For intel cpus enter intel-ucode, for amd am-ucode. Check output of /proc/cpuinfo above"
  echo "Check https://wiki.archlinux.org/title/microcode for more details"
  read MICROCODE
  export MICROCODE
fi

if [ -z "$LOCALE" ]
then
  echo "Enter locale (format xx_XX, for example en_US)"
  read LOCALE
  export LOCALE
fi

if [ -z "$TIMEZONE" ]
then
  curl -s 'http://ip-api.com/line?fields=timezone'
  echo "Enter timezone. Suggested autodetected timezone is $(curl -s 'http://ip-api.com/line?fields=timezone')"
  read TIMEZONE
  export TIMEZONE
fi

if [ -z "$USER_NAME" ]
then
  echo "Set name of user"
  read USER_NAME
  export USER_NAME
fi

if [ -z "$HOST_NAME" ]
then
  echo "Set hostname"
  read HOST_NAME
  export HOST_NAME
fi

if [ -z "$USER_PASSWORD" ]
then
  echo "Insert user password (you will not see it)"
  read -s USER_PASSWORD
  export USER_PASSWORD
fi

if [ -z "$MKINITCPIO_MODULES" ]
then
  echo "Insert comma separated modules to install in mkinitcpio image"
  read -s MKINITCPIO_MODULES
  export MKINITCPIO_MODULES
fi

