# Copyright (c) 2015-7 sakaki <sakaki@deciban.com>
# License: GPL 3.0+
# NO WARRANTY

# This script fragment will be sourced by the initial (boot) kernel's
# init script; it must in turn load the DTB and final (target) kernel,
# setup the kernel command line, and finally pass control over to the
# new kernel with kexec -e.
# Remember that this script is running in a fairly minimal busybox
# environment, and that the shell is ash, not bash.

# On entry, /boot is already mounted (read-only).

# adjust the following to suit your system...
ROOT="PARTUUID=05A8FC63-03"
DELAY=5
ROOTSPEC="rootfstype=ext4"
CONSOLE="console=ttyS0,115200n8 earlyprintk"
INITRAMFS="/boot/initramfs-linux.img"
DTB="/boot/kirkwood-b3.dtb"

# use the patched DTB, if provided
if [ -f "/boot/kirkwood-b3-earlyled.dtb" ]; then
    DTB="/boot/kirkwood-b3-earlyled.dtb"
fi

echo "Creating patched zImage from baseline version..."
cat /boot/cache_head_patch /boot/zImage > zImage
echo "Loading patched kernel and setting command line..."
# if an initramfs is present, use this
if [ -f "${INITRAMFS}" ]; then
  kexec --type=zImage --dtb="${DTB}" \
    --image="${INITRAMFS}" \
    --append="root=${ROOT} ${ROOTSPEC} rootdelay=${DELAY} ${CONSOLE}" \
    --load zImage
else
  kexec --type=zImage --dtb="${DTB}" \
    --append="root=${ROOT} ${ROOTSPEC} rootdelay=${DELAY} ${CONSOLE}" \
    --load zImage
fi
umount /boot
echo "Booting patched kernel with kexec..."
kexec -e
