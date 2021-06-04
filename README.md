# deployarch

This repository is meant as a way to simplify the [Arch Linux][arch] installation process.
The scripts are based on [this gist][gist] I made explaining the process of installing Arch Linux.
Furthermore, this repository contains my personal dotfile collection.

# Installation

To install Arch Linux using these scripts, start by installing Git to the Arch Linux
installation medium, then cloning the repository and executing `install`:

```sh
pacman -Sy git
git clone https://github.com/phntxx/deployarch
cd deployarch/
./install
```

Once `install` has completed, change onto the new Arch Linux installation, install git
there, clone the repository again, then run `post-install`. This will install additional
packages, as well as optionally set up the operating system with `open-vm-tools` and
other patches for running as a VMware virtual machine:

```sh
arch-chroot /mnt
cd ~

pacman -Sy git
git clone https://github.com/phntxx/deployarch
cd deployarch/
./post-install
```

Once `post-install` has completed, there are some steps that you need to do manually:

- Set the correct time zone
- Generate and save the locale

Both of these steps are documented [here][gist] in step 9, "Configuring the system".
As this is also where the root password is being set, I'd suggest looking over the
code yourself first to make sure that everything happens as you'd expect it to.
Once that is completed, simply unmount the disks and reboot:

```sh
exit
umount -r /mnt
reboot
```

# Optional additional steps

This repository contains two more scripts: `app-install` and `maintain`.

1. `app-install`: This script installs given packages using `pacman` and given AUR-packages
   through [`yay`][3]. It also installs `yay` itself. By default, the arrays are populated with
   applications that I personally require, so be sure to edit the script for your requirements.
2. `maintain`: This script runs through the steps from [this wiki-entry][maintain] and removes
   unnecessary packages.

[arch]: https://archlinux.org
[gist]: https://gist.github.com/phntxx/6dab61114d1bdc3397711f6675231964
[yay]: https://github.com/Jguer/yay
[maintain]: https://wiki.archlinux.org/title/System_maintenance
