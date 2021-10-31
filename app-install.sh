#!/bin/bash

#
# app-install.sh
# phntxx/installarch
#

set -o errexit
set -o nounset
set -o pipefail

# Define your packages here
pacman=(networkmanager-openvpn grub-customizer cmatrix discord chromium)
aur=(visual-studio-code-bin notion-app slack-desktop spotify 1password nerd-fonts-hack)

installPacmanPackages () {
  for package in "${pacman[@]}"; do
    sudo pacman -S $package --noconfirm
  done
}

installYay () {
  sudo pacman -S --needed git base-devel --noconfirm
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay
  makepkg -si
}

installYayPackages () {
  for package in "${aur[@]}"; do
    yay -S $package
  done
}

installPacmanPackages
installYay
installYayPackages
