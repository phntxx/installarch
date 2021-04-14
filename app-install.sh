#!/bin/bash

#
# app-install.sh
# phntxx/deployarch
#

#
# This script installs the following packages:
#
# pacman: urxvt, discord, chromium, gnome-tweaks, grub-customizer, cmatrix
# yay: vscode, notion, slack, spotify, hack nerd font
#

set -o errexit
set -o nounset
set -o pipefail

installPacmanPackages () {
  sudo pacman -S \
    rxvt-unicode \
    discord \
    chromium \
    gnome-tweaks \
    grub-customizer \
    cmatrix \
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
    nerd-fonts-hack
}


installPacmanPackages
installYay
installYayPackages
