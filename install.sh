#! /bin/bash

#
# install.sh
# phntxx/deployarch
#

set -o errexit
set -o nounset
set -o pipefail

checkInternet () {
  echo "Checking internet connection by pinging archlinux.org..."
  if ping -q -c 1 -W 1 archlinux.org > /dev/null; then
    echo "Internet connection check successful, continuing..."
  else
    echo "Internet connection check failed, exiting."
    exit
  fi
}

diskSetup () {

  validDiskInput=0
  while [ $validDiskInput -ne "1" ]; do
    read -p "What disk do you want to install Arch Linux on (e.g. /dev/sda)? " disk
    if [ -b $disk ]; then
      echo "Disk $disk is available, continuing..."
      validDiskInput=1
    else
      echo "Disk $disk is not available, retrying."
    fi
  done

  validSwapInput=0
  while [ $validSwapInput -ne "1" ]; do
    read -p "How much disk space should be allocated to the swap partition (e.g. 5G)? " swap
    if [[ $swap =~ ^[1-9][0-9]*[MG]$ ]]; then
        echo "Swap partition will be $swap in size, continuing..."
        validSwapInput=1
    else
      echo "Invalid Input, retrying."
    fi
  done

  echo "This script will now partition and format your disk as follows:"
  echo "Partition 1: 300M, mounted at /mnt/boot, used for GRUB"
  echo "Partition 2: XXXM, used for swap"
  echo "Partition 3: remaining disk space, used for Arch Linux"
  echo "During this process, all of the data that is currently on the disk will be lost."

  validConfirmInput=0
  while [ $validConfirmInput -ne "1" ]; do

    read -p "Do you want to continue? [Y/N] " formatConfirm

    if [ $formatConfirm == "y" ] || [ $formatConfirm == "Y" ]; then
      validConfirmInput=1
      echo "Agreed to partitioning and formatting, continuing..."
    elif [ $formatConfirm == "n" ] || [ $formatConfirm == "N" ]; then
      validConfirmInput=1
      echo "User did not agree to partitioning and formatting, exiting."
      exit
    else
      echo "Invalid Input, retrying."
    fi
  done

  echo "Partitioning disk..."
  (
    echo o      # clear the partition table from memory
    echo n      # create a new partition
    echo p      # set the new partition as the primary partition
    echo 1      # set the partition number to 1
    echo        # default: start partition at the beginning of the disk
    echo +300M  # make the new partition 300M big
    echo n      # create a new partition
    echo p      # set the new partition as the primary partition
    echo 2      # set the partition number to 2
    echo        # default: start partition after partition 1
    echo +$swap # make the new partition as big as the user wanted
    echo n      # create a new partition
    echo p      # set the new partition as the primary partition
    echo 3      # set the partition number to 3
    echo        # default: start partition after partition 2
    echo        # default: make partition as big as the remaining disk space
    echo a      # make a partition bootable
    echo 1      # set partition 1 as the bootable partition
    echo w      # write the new partition table to memory
    echo q      # exit fdisk
  ) | fdisk $disk

  echo "Formatting disk, enabling and mounting partitions..."

  mkfs.fat -F 32 ${disk}1
  mkfs.ext4 ${disk}3

  mkswap ${disk}2
  swapon ${disk}2

  mount ${disk}3 /mnt
  mkdir /mnt/boot
  mount ${disk}1 /mnt/boot
}

updateClock () {
  echo "Enabling NTP..."
  timedatectl set-ntp true
}

installArch () {
  echo "Installing Arch Linux..."
  pacstrap /mnt base base-devel linux linux-firmware
}

if [[ $EUID -eq 0 ]]; then
   checkInternet
   diskSetup
   updateClock
   installArch
else
  echo "This script must be run as root."
  exit
fi