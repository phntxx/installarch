#!/bin/bash

#
# install-dwm.sh
# phntxx/deployarch
#

set -o errexit
set -o nounset
set -o pipefail

function downloadSoftware {
  pacman -S git --noconfirm
  git clone https://git.suckless.org/dwm /usr/src/dwm
  git clone https://git.suckless.org/st /usr/src/st
  git clone https://git.suckless.org/slstatus /usr/src/slstatus
  git clone https://git.suckless.org/surf /usr/src/surf
}

function copyConfigs {
  #cp $PWD/configs/dwm/config.h /usr/src/dwm/config.h
  cp $PWD/configs/slstatus/config.h /usr/src/slstatus/config.h

  validUsernameInput=0
  while [ $validUsernameInput -ne "1" ]; do

    read -p "For which users should dwm start on startx? " username

    getent passwd $username > /dev/null 2&>1
    if [ $? -ne 0 ]; then
      validUsernameInput=1
      cp $PWD/configs/.xinitrc /home/$username/.xinitrc
    else
      echo "User doesn't exist, retrying."
    fi
  done
}

function makeSoftware {
  cd /usr/src/dwm
  make clean install
  cd /usr/src/st
  make clean install
  cd /usr/src/slstatus
  make clean install
  cd /usr/src/surf
  make clean install
}

if [[ $EUID -eq 0 ]]; then
  downloadSoftware
  copyConfigs
  makeSoftware
else
  echo "This script must be run as root."
  exit
fi