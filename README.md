# deployarch

This repository is meant as a way to simplify the [Arch Linux][1] installation process.
The scripts are based on [this gist][2] I made explaining the process of installing Arch Linux.

# Installation

To install Arch Linux using these scripts, start by installing Git to the Arch Linux installation medium, then cloning the repository and executing `install.sh`:

```sh
pacman -Sy git
git clone https://github.com/phntxx/deployarch
cd deployarch/
./install.sh
```

Once `install.sh` has completed, change onto the new Arch Linux installation, install git there, clone the repository again, then run `post-install.sh`. This will install additional packages, as well as optionally set up the operating system with `open-vm-tools` and other patches for running as a VMware virtual machine:

```sh
arch-chroot /mnt
cd ~

pacman -Sy git
git clone https://github.com/phntxx/deployarch
cd deployarch/
./post-install.sh
```

Once `post-install.sh` has completed, there are some steps that you need to do manually:

- Set the correct time zone
- Generate and save the locale

Both of these steps are documented [here][2] in step 9, "Configuring the system".

Once that is completed, simply unmount the disks and reboot:

```sh
exit
umount -r /mnt
reboot
```

[1]: https://archlinux.org
[2]: https://gist.github.com/phntxx/6dab61114d1bdc3397711f6675231964
