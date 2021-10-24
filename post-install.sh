#! /bin/bash

#
# post-install.sh
# phntxx/deployarch
#

set -o errexit
set -o nounset
set -o pipefail
 
yesNo () {
  local validInput=0
  while [ $validInput -ne "1" ]; do

    read -p "$1 [Y/N] " entry

    if [ $entry == "y" ] || [ $entry == "Y" ]; then
      validInput=1
      eval $2=1

    elif [ $entry == "n" ] || [ $entry == "N" ]; then
      validInput=1
      eval $2=0
    else
      echo "Invalid input, retrying."
    fi
  done
}

installPackages () {
  echo "Installing efibootmgr, dosfstools, gptfdisk, grub, networkmanager, sudo and vim..."
  pacman -Sy efibootmgr dosfstools gptfdisk grub networkmanager sudo vim --noconfirm
  systemctl enable NetworkManager
}

configureVM () {

  yesNo "Is this Arch Linux install running inside of a VMware virtual machine?" res
  if [ "$res" -eq "1" ]; then
    echo "Installing open-vm-tools..."
    pacman -S open-vm-tools --noconfirm
    systemctl enable vmtoolsd.service
    systemctl enable vmware-vmblock-fuse.service
  fi

  yesNo "Do you require VMware graphics patches?" res
  if [ "$res" -eq "1" ]; then
    echo "Installing VMware graphics drivers..."
    pacman -S xf86-input-vmmouse xf86-video-vmware mesa gtk2 gtkmm --noconfirm
    echo needs_root_rights=yes >> /etc/X11/Xwrapper.config
    systemctl enable vmtoolsd
  fi
}

configureSystem () {

  read -p "What is your keyboard layout?" keyboardLayout

  echo "Setting $keyboardLayout as the layout in /etc/vconsole.conf..."

  touch /etc/vconsole.conf
  echo "KEYMAP=$keyboardLayout" >> /etc/vconsole.conf

  read -p "What is the hostname of this machine?" hostname

  echo "Setting $hostname as the hostname of this machine in /etc/hostname..."

  touch /etc/hostname
  echo "$hostname" >> /etc/hostname

  echo "Adding the appropriate entries in /etc/hosts..."

  echo "127.0.0.1 localhost" >> /etc/hosts
  echo "::1 localhost" >> /etc/hosts
  echo "127.0.0.1 $hostname.localdomain $hostname" >> /etc/hosts
}

installBootloader () {
  echo "Installing GRUB..."
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch_grub --recheck --debug
  mkdir -p /boot/grub/locale
  cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
  grub-mkconfig -o /boot/grub/grub.cfg
  echo "Done installing GRUB."
}

setRootPassword () {
  echo "Setting root password..."
  passwd
  echo "Done setting root password."
}

finalize () {
  echo "Your Arch Linux installation is now pretty much done, but there's some steps this script cannot execute."
  echo "Please complete the following steps before rebooting:"
  echo "1. Set the correct time zone"
  echo "2. Generate and save your locale"
  echo "Thank you for using these scripts and have fun with Arch Linux!"
}

if [[ $EUID -eq 0 ]]; then
  installPackages
  configureVM
  configureSystem
  installBootloader
  setRootPassword
  finalize
else
  echo "This script must be run as root."
  exit
fi
