#! /bin/bash

#
# install.sh
# phntxx/deployarch
#

function checkInternet {
  echo "Checking internet connection by pinging archlinux.org..."
  if ping -q -c 1 -W 1 archlinux.org > /dev/null; then
    echo "Internet connection check successful, continuing..."
  else
    echo "Internet connection check failed, exiting."
    exit
  fi
}

function updateClock {
  echo "Enabling NTP..."
  timedatectl set-ntp true
}

function diskSetup {

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
  # https://superuser.com/a/332322

  (
    echo o
    echo n
    echo p
    echo 1
    echo 
    echo +300M
    echo n
    echo p
    echo 2
    echo 
    echo +$swap
    echo n
    echo p
    echo 3
    echo 
    echo 
    echo a
    echo 1
    echo p
    echo w
    echo q
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

function installArch {
  echo "Installing Arch Linux..."
  pacstrap /mnt base base-devel linux linux firmware
}

if [[ $EUID -eq 0 ]]; then
   checkInternet
   updateClock
   diskSetup
   installArch
else
  echo "This script must be run as root."
  exit
fi