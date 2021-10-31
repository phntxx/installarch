# Install Arch Linux

A set of simple shell scripts that allow for a quick and easy installation of
[Arch Linux][arch]. This repository is based on [this gist][gist] I made a while
ago, where I go into the installation procedure in more detail.

## Usage

To install Arch Linux using these scripts, follow these instructions:

1. Create an Arch Linux install medium by [downloading the latest ISO-file][download]
   and burning it to a DVD or USB-drive.
2. Boot your PC from the install medium and make sure your system is running in
   EFI mode and has a network connection. This can be checked for using these commands:
   ```sh
   # Check if the system is booted in EFI mode. If this directory exists, you're
   # in EFI mode.
   ls /sys/firmware/efi/efivars
   # Check if your system has a network connection and is able to resolve domain
   # names. If this doesn't throw any errors, you're good.
   ping archlinux.org
   ```
3. Install `git` and clone this repository:
   ```sh
   pacman -Sy git
   git clone https://github.com/phntxx/installarch
   ```
4. Go into the repository and run `install.sh`:
   ```sh
   cd installarch/
   ./install.sh
   ```
5. Once `install` has completed, copy the repository to the new Arch Linux
   installation and continue by running `post-install.sh` there:
   ```sh
   cd ..
   cp -r installarch /mnt/root
   arch-chroot /mnt
   cd ~
   ./post-install.sh
   ```
   As this is also where the root password is being set, I'd suggest looking over the
   code yourself first to make sure that everything happens as you'd expect it to.
6. Once `post-install.sh` has completed, there are some steps that you need to do  
   manually:

   1. Set the correct time zone
   2. Generate and save the locale

   Both of these steps are documented [here][gist] in step 9, "Configuring the
   system".

7. Once that is completed, simply unmount the disks and reboot:
   ```sh
   exit
   umount -r /mnt
   reboot
   ```

**And with that, you're done! I wish you good luck on your Arch Linux journey!**

## Further optional steps

This repository contains two more scripts: `app-install` and `maintain`.

1. `app-install.sh`: This script installs given packages using `pacman` and given
   AUR-packages through [`yay`][3]. It also installs `yay` itself. By default, the
   arrays are populated with applications that I personally require, so be sure to
   edit the script for your requirements.
2. `maintain.sh`: This script runs through the steps from [this wiki-entry][maintain]
   and removes unnecessary packages.

[arch]: https://archlinux.org
[download]: https://archlinux.org/download/
[gist]: https://gist.github.com/phntxx/6dab61114d1bdc3397711f6675231964
[yay]: https://github.com/Jguer/yay
[maintain]: https://wiki.archlinux.org/title/System_maintenance
