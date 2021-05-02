#!/bin/bash

#
# maintain.sh
# phntxx/deployarch
#

set -o errexit
set -o nounset
set -o pipefail

# This list is from https://github.com/lahwaacz/Scripts/blob/master/rmshit.py

removable=(
  "$HOME/.adobe"
  "$HOME/.macromedia"
  "$HOME/.recently-used"
  "$HOME/.local/share/recently-used.xbel"
  "$HOME/.thumbnails"
  "$HOME/.gconfd"
  "$HOME/.gconf"
  "$HOME/.local/share/gegl-0.2"
  "$HOME/.FRD/log/app.log"
  "$HOME/.FRD/links.txt"
  "$HOME/.objectdb"
  "$HOME/.gstreamer-0.10"
  "$HOME/.pulse"
  "$HOME/.esd_auth"
  "$HOME/.config/enchant"
  "$HOME/.spicec"
  "$HOME/.dropbox-dist"
  "$HOME/.parallel"
  "$HOME/.dbus"
  "$HOME/ca2"
  "$HOME/ca2~"
  "$HOME/.distlib/" 
  "$HOME/.bazaar/"
  "$HOME/.bzr.log"
  "$HOME/.nv/"
  "$HOME/.viminfo"
  "$HOME/.npm/"
  "$HOME/.java/"
  "$HOME/.oracle_jre_usage/"
  "$HOME/.jssc/"
  "$HOME/.tox/"
  "$HOME/.pylint.d/"
  "$HOME/.qute_test/"
  "$HOME/.QtWebEngineProcess/"
  "$HOME/.qutebrowser/" 
  "$HOME/.asy/"
  "$HOME/.cmake/"
  "$HOME/.gnome/"
  "$HOME/unison.log"
  "$HOME/.texlive/"
  "$HOME/.w3m/"
  "$HOME/.subversion/"
  "$HOME/nvvp_workspace/"
  "$HOME/.ansible/"
  "$HOME/.fltk/"
  "$HOME/.vnc/"
)

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

checkForErrors () {
  echo "Checking for errors..."

  echo "Running 'systemctl --failed'..."
  sudo systemctl --failed

  echo "Running 'journalctl -p 3 -xb'..."
  sudo journalctl -p 3 -xb
}

cleanYay () {
  echo "Removing unneeded yay dependencies..."

  echo "Running 'yay -Yc'..."
  yay -Yc  
}

cleanPacman () {

  echo "Removing unneeded packages"

  echo "Running 'pacman -Qdtq'..."

  {
    pacman -Qdtq && 
    echo "Running 'pacman -Rcns \$(pacman -Qdtq)'..." && 
    sudo pacman -Rcns $(pacman -Qdtq)
  } || {
    echo "No unneeded packages found."
  }

  echo "Clearing pacman cache..."

  echo "Running 'pacman -Scc'..."
  sudo pacman -Scc
}

upgradeYay () {
  echo "Updating AUR packages..."

  echo "Running 'yay -Syu'..."
  yay -Syu
}

upgradePacman () {
  echo "Updating Pacman packages..."

  echo "The Arch Linux Wiki advises that you check the news"
  echo "on the Arch Linux website (https://archlinux.org)."

  echo "Running 'pacman -Syu'..."
  sudo pacman -Syu
}

cleanHome () {

  local foundItems=()

  for item in ${removable[@]}; do
    if [[ -d "$item" || -e "$item" || -f "$item" ]]; then
      foundItems+=("$item")
    fi
  done

  echo "Found these files:"
  for item in ${foundItems[@]}; do
    echo "$item"
  done
  echo ""

  yesNo "Do you want to delete all of the files listed?" res
  if [ "$res" -eq 1 ]; then
    echo "Deleting listed files..."
    for item in ${removable[@]}; do
        rm -rf "$item"
    done
  elif [ "$res" -eq 0 ]; then
    echo "Not deleting any files."
  fi
}

restart () {

  echo "The Arch Linux wiki recommends rebooting after an upgrade."

  yesNo "Do you want to reboot now?" res
  if [ "$res" -eq "1" ]; then
    echo "Rebooting..."
    sudo reboot
  elif [ "$res" -eq "0" ]; then
    echo "Not rebooting."
  fi
}

checkForErrors
cleanYay
cleanPacman
upgradeYay
upgradePacman
cleanHome
