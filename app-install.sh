#!/bin/bash

#
# app-install.sh
# phntxx/deployarch
#

set -o errexit
set -o nounset
set -o pipefail

installPacmanPackages () {
  sudo pacman -S \
    networkmanager-openvpn \
    grub-customizer \
    cmatrix \
    discord \
    chromium \
    thunderbird \
  --noconfirm
}

installYay () {
  sudo pacman -S --needed git base-devel --noconfirm
  git clone https://aur.archlinux.org/yay.git /tmp/yay
  cd /tmp/yay
  makepkg -si
}

installYayPackages () {
  yay -S \
    visual-studio-code-bin \
    notion-app \
    slack-desktop\
    spotify \
    1password \
    nerd-fonts-hack
}

installPacmanPackages
installYay
installYayPackages
