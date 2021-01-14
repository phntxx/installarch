#!/bin/bash

#
# install-dwm.sh
# phntxx/deployarch
#

set -o errexit
set -o nounset
set -o pipefail

function downloadSoftware {
  pacman -S git xorg glibc ttf-font-fontawesome wget --noconfirm
  git clone https://git.suckless.org/dwm /usr/src/dwm
  git clone https://git.suckless.org/st /usr/src/st
  git clone https://git.suckless.org/dmenu /usr/src/dmenu
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
    if [ $? -eq 0 ]; then
      validUsernameInput=1
      cp $PWD/configs/.xinitrc /home/$username/.xinitrc
      chown $username:users /home/$username/.xinitrc
    else
      echo "User doesn't exist, retrying."
    fi
  done
}

function configurePatches {
  validPatchInput=0
  while [ $validPatchInput -ne "1" ]; do

    read -p "Apply custom patches? [Y/N]" patchConfirm

    if [ $patchConfirm == "y" ] || [ $patchConfirm == "Y" ]; then
      validPatchInput=1
      applyPatches
    elif [ $patchConfirm == "n" ] || [ $patchConfirm == "N" ]; then
      validPatchInput=1
    else
      echo "Invalid input, retrying."
    fi
  done
}

function applyPatches {
  
  mkdir -p /usr/src/st/patches
  wget https://st.suckless.org/patches/anysize/st-anysize-0.8.1.diff -O /usr/src/st/patches/st-anysize.diff
  wget https://st.suckless.org/patches/clipboard/st-clipboard-0.8.3.diff -O /usr/src/st/patches/st-clipboard.diff
  wget https://st.suckless.org/patches/scrollback/st-scrollback-0.8.4.diff -O /usr/src/st/patches/st-scrollback.diff

  git -C /usr/src/st apply /usr/src/st/patches/st-anysize.diff
  git -C /usr/src/st apply /usr/src/st/patches/st-clipboard.diff
  git -C /usr/src/st apply /usr/src/st/patches/st-scrollback.diff

  mkdir -p /usr/src/dwm/patches
  wget https://dwm.suckless.org/patches/launcher/dwm-launchers-20200527-f09418b.diff -O /usr/src/dwm/patches/dwm-launcher.diff
  git -C /usr/src/dwm apply /usr/src/dwm/patches/dwm-launcher.diff
}

function makeSoftware {
  make -C /usr/src/dwm -f /usr/src/dwm/Makefile clean install
  make -C /usr/src/st -f /usr/src/st/Makefile clean install
  make -C /usr/src/dmenu -f /usr/src/dmenu/Makefile clean install
  make -C /usr/src/slstatus -f /usr/src/slstatus/Makefile clean install
  make -C /usr/src/surf -f /usr/src/surf/Makefile clean install
}

if [[ $EUID -eq 0 ]]; then
  downloadSoftware
  copyConfigs
  configurePatches
  makeSoftware
else
  echo "This script must be run as root."
  exit
fi
