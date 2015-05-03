#!/bin/bash
# Copyright (c) 2015 sakaki <sakaki@deciban.com>
# License: GPL 3.0+
# NO WARRANTY
#
# Installs Gentoo system on /dev/sda, using default settings.
# Adapt to your requirements.
# WARNING - will delete the contents of /dev/sda!

set -e
set -u
set -o pipefail

LOG=/var/log/gentoo_install.log

if grep -q "/dev/sda" /proc/mounts; then
    echo "Please unmount any /dev/sda partitions first - exiting" >&2
    exit 1
fi
echo "Install Gentoo -> /dev/sda (B3's internal HDD)"
echo
echo "WARNING - will delete anything currently on HDD"
echo "(including any existing Excito Debian system)"
echo "Please make sure you have adequate backups before proceeding"
echo
echo "Type (upper case) INSTALL and press Enter to continue"
read -p "Any other entry quits without installing: " REPLY
if [[ ! "${REPLY}" == "INSTALL" ]]
then
    echo "You did not type INSTALL - exiting" >&2
    exit 1
fi
echo "Installing: check '$LOG' in case of errors"
echo "Step 1 of 5: creating partition table on /dev/sda..."
echo "o
n
p
1

+64M
a
n
p
2

+1G
t
2
82
n
p
3


p
w" | fdisk /dev/sda >"${LOG}" 2>&1

echo "Step 2 of 5: formatting partitions on /dev/sda..."
mkfs.ext3 -F -L "boot" /dev/sda1 >>"${LOG}" 2>&1
mkswap -L "swap" /dev/sda2 >>"${LOG}" 2>&1
mkfs.ext4 -F -L "root" /dev/sda3 >>"${LOG}" 2>&1

echo "Step 3 of 5: mounting boot and root partitions from /dev/sda..."
mkdir -p /mnt/{sdaboot,sdaroot} >>"${LOG}" 2>&1
mount /dev/sda1 /mnt/sdaboot >>"${LOG}" 2>&1
mount /dev/sda3 /mnt/sdaroot >>"${LOG}" 2>&1

echo "Step 4 of 5: copying system and bootfiles (please be patient)..."
mkdir -p /mnt/sdaboot/boot >>"${LOG}" 2>&1
cp -ax /root/root-on-sda3-kernel/{uImage,config,System.map} /mnt/sdaboot/boot/ >>"${LOG}" 2>&1
cp -ax /bin /dev /etc /home /lib /root /sbin  /tmp /usr /var /mnt/sdaroot/ >>"${LOG}" 2>&1
mkdir -p /mnt/sdaroot/{boot,media,mnt,opt,proc,run,sys} >>"${LOG}" 2>&1
cp /root/fstab-on-b3 /mnt/sdaroot/etc/fstab >>"${LOG}" 2>&1

echo "Step 5 of 5: syncing filesystems and unmounting..."
sync >>"${LOG}" 2>&1
umount -l /mnt/{sdaboot,sdaroot} >>"${LOG}" 2>&1
rmdir /mnt/{sdaboot,sdaroot} >>"${LOG}" 2>&1

echo 'All done! You can reboot into your new system now.'
