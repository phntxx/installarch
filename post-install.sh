#! /bin/bash

#
# post-install.sh
# phntxx/deployarch
#

set -o errexit
set -o nounset
set -o pipefail

function installPackages {
  echo "Installing efibootmgr, dosfstools, gptfdisk, grub, networkmanager, sudo and vim..."
  pacman -Sy efibootmgr dosfstools gptfdisk grub networkmanager sudo vim --noconfirm
}

function configureVM {
  validVMInput=0
  while [ $validVMInput -ne "1" ]; do

    read -p "Is this Arch Linux install running inside of a VMware virtual machine? [Y/N]" vmConfirm

    if [ $vmConfirm == "y" ] || [ $vmConfirm == "Y" ]; then
      validVMInput=1
      installVMTools
    elif [ $vmConfirm == "n" ] || [ $vmConfirm == "N" ]; then
      validVMInput=1
    else
      echo "Invalid input, retrying."
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
      echo "Invalid input, retrying."
    fi
  done

}

function installVMTools {
  echo "Installing open-vm-tools..."
  pacman -S open-vm-tools --noconfirm
  systemctl enable --now vmtoolsd.service
  systemctl enable --now vmware-vmblock-fuse.service
}

function installVMGFX {
  echo "Installing VMware graphics drivers..."
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

function setRootPasswd {
  validPasswdInput=0
  while [ $validPasswdInput -ne "1" ]; do

    read -s -p "Enter the new root password: " rootPasswd
    read -s -p "Enter the new root password again (verification): " verifyPasswd

    if [ $rootPasswd == $verifyPasswd ]; then
      validPasswdInput=1
      echo "Passwords match, setting root password..."
      echo "root:$rootPasswd" | chpasswd
    else
      echo "Passwords do not match, retrying."
    fi
  done
}

function configureNewUser {
  validUserInput=0
  while [ $validUserInput -ne "1" ]; do

    read -p "Do you want to create a new user? [Y/N] " userConfirm

    if [ $userConfirm == "y" ] || [ $userConfirm == "Y" ]; then
      validUserInput=1
      createNewUser
    elif [ $userConfirm == "n" ] || [ $userConfirm == "N" ]; then
      validUserInput=1
    else
      echo "Invalid input, retrying."
    fi
  done
}

function createNewUser {
  validUsernameInput=0
  while [ $validUsernameInput -ne "1" ]; do

    read -p "Enter a new username: " username

    getent passwd $username > /dev/null 2&>1

    if [ $? -ne 0 ]; then
      validUsernameInput=1
      echo "Creating new user $username..."
      useradd -m -g users -s /bin/bash $username
      echo "The new user $username has been created. You still need to give them sudo permissions (if needed)."
    else
      echo "User already exists, retrying."
    fi
  done
}

function finalize {
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
  setRootPasswd
  configureNewUser
else
  echo "This script must be run as root."
  exit
fi