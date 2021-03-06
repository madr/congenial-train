echo "Setup system clock"
echo "--------------------------------------------------"
ln -s /usr/share/zoneinfo/Europe/Stockholm /etc/localtime

echo "Set the hostname"
echo "--------------------------------------------------"
echo "Moridin" > /etc/hostname

echo "Update locale"
echo "--------------------------------------------------"
echo "LANG=en_US.UTF-8" >> /etc/locale.conf
echo "LANGUAGE=en_US" >> /etc/locale.conf
echo "LC_ALL=C" >> /etc/locale.conf
echo "KEYMAP=sv-latin1" >> /etc/vconsole.conf
sed -i 's/^#sv_SE/sv_SE/' /etc/locale.gen
locale-gen

echo "Set password for root"
echo "--------------------------------------------------"
passwd

echo "Add real user"
echo "--------------------------------------------------"
# remove -s flag if you don't whish to use zsh
useradd -m -g users -G wheel -s /bin/zsh ay
passwd ay

echo "Configure mkinitcpio with modules needed for the initrd image"
echo "--------------------------------------------------"
sed -i -r 's/MODULES=\((.*)\)/MODULES=\(ext4 \1\)/' /etc/mkinitcpio.conf
sed -i -r 's/HOOKS=\((.*) filesystems (.*)\)/HOOKS=\(\1 encrypt lvm2 filesystems \2\)/' /etc/mkinitcpio.conf

echo "Regenerate initrd image"
echo "--------------------------------------------------"
mkinitcpio -p linux

echo "Setup grub"
echo "--------------------------------------------------"
grub-install
sed -i -r 's/GRUB_CMDLINE_LINUX=.+/GRUB_CMDLINE_LINUX="cryptdevice=\/dev\/sda3:luks:allow-discards"/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
