#! /bin/bash

#
# post-install.sh
# phntxx/deployarch
#

#!/bin/bash

function installPackages {
  echo "Installing efibootmgr, dosfstools, gptfdisk, grub, networkmanager and vim..."
  pacman -Sy efibootmgr dosfstools gptfdisk grub networkmanager vim --noconfirm
}

function configureVM {
  validVMInput=0
  while [ $validInput -ne "1" ]; do

    read -p "Is this Arch Linux install running inside of a VMware virtual machine? [Y/N]" vmConfirm

    if [ $vmConfirm == "y" ] || [ $vmConfirm == "Y" ]; then
      validVMInput=1
      installVMTools
    elif [ $vmConfirm == "n" ] || [ $vmConfirm == "N" ]; then
      validVMInput=1
    else
      echo "Invalid Input. Please try again."
    fi
  done

  validGFXInput=0
  while [ $validGFXInput -ne "1" ]; do

    read -p "Do you require VMware graphics patches? [Y/N]" gfxConfirm

    if [ $gfxConfirm == "y" ] || [ $gfxConfirm == "Y" ]; then
      validGFXInput=1
      installVMGFX
    elif [ $gfxConfirm == "n" ] || [ $gfxConfirm == "N" ]; then
      validGFXInput=1
    else
      echo "Invalid Input. Please try again."
    fi
  done

}

function installVMTools {
  echo "Installing open-vm-tools"
  pacman -S open-vm-tools --noconfirm
  systemctl enable --now vmtoolsd.service
  systemctl enable --now vmware-vmblock-fuse.service
}

function installVMGFX {
  echo "Installing VMware graphics drivers"
  pacman -S xf86-input-vmmouse xf86-video-vmware mesa gtk2 gtkmm --noconfirm
  echo needs_root_rights=yes >> /etc/X11/Xwrapper.config
}

function configureSystem {

  read -e "What is your keyboard layout?" keyboardLayout

  echo "Setting $keyboardLayout as the layout in /etc/vconsole.conf..."

  touch /etc/vconsole.conf
  echo "KEYMAP=$keyboardLayout" >> /etc/vconsole.conf

  read -e "What is the hostname of this machine?" hostname

  echo "Setting $hostname as the hostname of this machine in /etc/hostname..."

  touch /etc/hostname
  echo "$hostname" >> /etc/hostname

  echo "Adding the appropriate entries in /etc/hosts..."

  echo "127.0.0.1 localhost" >> /etc/hosts
  echo "::1 localhost" >> /etc/hosts
  echo "127.0.0.1 $hostname.localdomain $hostname" >> /etc/hosts
}

function installBootloader {
  echo "Installing GRUB..."
  grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=arch_grub --recheck --debug
  mkdir /boot/grub/locale
  cp /usr/share/locale/en\@quot/LC_MESSAGES/grub.mo /boot/grub/locale/en.mo
  grub-mkconfig -o /boot/grub/grub.cfg
}

if [[ $EUID -eq 0 ]]; then
   installPackages
   configureVM
   configureSystem
   installBootloader
else
  echo "This script must be run as root."
  exit
fi