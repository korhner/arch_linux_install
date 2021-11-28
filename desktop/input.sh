#!/usr/bin/env bash

set -e

if [ -z "$DESKTOP" ]
then
  echo "Insert desktop. Supported values: $(ls desktop)"
  read DESKTOP
  export DESKTOP
fi