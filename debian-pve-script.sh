#!/bin/bash

###############################################################################
# GNU General Public License v3.0                                             #
# Copyright (c) 2023 Valentino Međimorec                                      #
#                                                                             #
# Simple script to add swap to debian, and install optional packages          #
#                                                                             #                                                                          #
###############################################################################

# Function to display script usage.
usage() {
 echo "Usage: $0 [OPTIONS]"
 echo "Options:"
 echo " -h, --help      Display this help message"
 echo " -s, --size      Set size for swap as numeric, the units are always GB. Example if you want to have 8GB swap: 8"
 echo " -p, --packages  List comma separated packages which needs to be installed. Example: rsync,git,curl"
}

while getopts "h:s:p:" options; do
  case "${options}" in
  h)
    usage
    exit
    ;;
  s)
    SIZE=${OPTARG}
    ;;
  p)
    PACKAGES=${OPTARG}
    ;;
  :)
    echo "Error: -${OPTARG} requires an argument."
    ;;
  *)
    exit_error
    ;;
  esac
done

if [ -z "$SIZE" ]
  then
    # Use simple debian approach - double it.
    MEMORY=$(free -g -t -t | grep -oP '\d+' | sed '1!d')
    SIZE=$((MEMORY * 2))

    echo "Automatic calculating swap size ==> $SIZE GB."
else
  echo "Swap size ==> $SIZE GB."
fi

# If we have a list of additional packages, convert it to a space separated list.
if [ -n "$PACKAGES" ]; then
  PACKAGES="${PACKAGES//,/ }"
  echo "Additional packages to be installed ==> $PACKAGES"
fi

if [ "$(whoami)" != "root" ]; then
        echo "Script must be run as root"
        exit 1
fi

SWAP=$(cat /proc/swaps)

# User could have zram partition, swap file, etc.
if [[ $SWAP = *'partition'* ]] || [[ $SWAP = *'file'* ]]; then
      echo "Swap already exists"
      cat /proc/swaps
      exit 1
fi

fallocate -l "$SIZE"G /swapfile || exit
chmod 600 /swapfile || exit
mkswap /swapfile || exit
swapon /swapfile || exit

echo "/swapfile swap swap defaults 0 0" >> "/etc/fstab" || exit

echo "Set swap ($SIZE GB) successfully"

if [ -n "$PACKAGES" ]; then
  for PACKAGE in $PACKAGES
    do
      apt install "$PACKAGE" -y || exit
      echo "Installed package => " "$PACKAGE"
    done
fi

free -m || exit
echo "Done!"
