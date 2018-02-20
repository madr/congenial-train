#!/bin/bash

echo "Set swedish keymap"
loadkeys sv-latin1

echo "Create partitions"
echo "--------------------------------------------------"
cgdisk /dev/sda
#1 100MB EFI partition    Hex code ef00
#2 250MB Boot partition   Hex code 8300
#3 100% size partiton     (to be encrypted) Hex code 8300

mkfs.vfat -F32 /dev/sda1
mkfs.ext2 /dev/sda2

echo "Setup the encryption of the system"
echo "--------------------------------------------------"
cryptsetup -c aes-xts-plain64 -y --use-random luksFormat /dev/sda3
cryptsetup luksOpen /dev/sda3 luks

echo "Create encrypted partitions"
echo "--------------------------------------------------"
pvcreate /dev/mapper/luks
vgcreate vg0 /dev/mapper/luks
lvcreate --size 8G vg0 --name swap
lvcreate -l +100%FREE vg0 --name root

echo "Create filesystems on encrypted partitions"
echo "--------------------------------------------------"
mkfs.ext4 /dev/mapper/vg0-root
mkswap /dev/mapper/vg0-swap

echo "Mount the new system" 
echo "--------------------------------------------------"
mount /dev/mapper/vg0-root /mnt # /mnt is the installed system
swapon /dev/mapper/vg0-swap # Not needed but a good thing to test
mkdir /mnt/boot
mount /dev/sda2 /mnt/boot
mkdir /mnt/boot/efi
mount /dev/sda1 /mnt/boot/efi

echo "Sort Mirrors"
echo "--------------------------------------------------"
cp /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.backup
sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist.backup
rankmirrors -n 6 /etc/pacman.d/mirrorlist.backup > /etc/pacman.d/mirrorlist

echo "Install the system"
# Install the system also includes stuff needed for starting wifi when first booting into the newly installed system
# Unless vim and zsh are desired these can be removed from the command
pacstrap /mnt base base-devel grub-efi-x86_64 zsh vim git efibootmgr dialog wpa_supplicant

echo "'install' fstab"
echo "--------------------------------------------------"
genfstab -pU /mnt >> /mnt/etc/fstab
echo "tmpfs	/tmp	tmpfs	defaults,noatime,mode=1777	0	0" >> /mnt/etc/fstab

echo "Enter new system"
echo "--------------------------------------------------"
arch-chroot /mnt "bash <(curl -L -s https://raw.githubusercontent.com/madr/congenial-train/master/moridin.sh)"

echo "Unmount all partitions"
echo "--------------------------------------------------"
umount -R /mnt
swapoff -a

echo "Reboot into the new system, don't forget to remove the cd/usb"
echo "--------------------------------------------------"
reboot
