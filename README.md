Install ARCH Linux with encrypted file-system and UEFI The official installation guide (https://wiki.archlinux.org/index.php/Installation_Guide) contains a more verbose description.

Download the archiso image from https://www.archlinux.org/, Copy to a usb-drive:

    dd if=archlinux.img of=/dev/sdX bs=16M && sync  # on linux

Boot from the usb. If the usb fails to boot, make sure that secure boot is disabled in the BIOS configuration.

If a wifi only system...

    wifi-menu

When an Internet connection is established, start install.

    pacman -S git
    git clone https://github.com/madr/congenial-train.git
    cd congenial-train
    ./moridin-init.sh
