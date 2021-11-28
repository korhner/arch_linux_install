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