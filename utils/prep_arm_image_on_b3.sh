#!/bin/bash
# Prepare B3 image, switching off cache, and appending DTB; also
# creates and copies over modules.
# Execute in top-level kernel directory.
# This version is intended to be run natively on the b3, which has a
# /boot partition.
# The partition will be mounted if necessary.
# Copyright (c) 2014 sakaki <sakaki@deciban.com>
# License: GPL 3.0+
# NO WARRANTY
set -e
set -u
die() { cat <<< "$@" 1>&2; exit 1; }
NUMTHREADS=$(( $(grep -E 'processor\s+:' /proc/cpuinfo | wc -l) + 1 ))
DNAME="$(readlink --canonicalize "${PWD}")"
KNAME="$(basename "${DNAME}")"
KNAME="${KNAME/linux-/Linux }"
declare -i DIDMOUNT=0
if ! grep -qs "/boot" /proc/mounts; then
    echo "Mounting /boot..."
    mount /boot
    DIDMOUNT=1
else
    echo "/boot is already mounted, leaving it that way..."
fi
echo "Compiling kernel (${KNAME})..."
make -j${NUMTHREADS} zImage
echo "Compiling DTB..."
make kirkwood-b3.dtb
echo "Compiling modules..."
make -j${NUMTHREADS} modules
echo "Installing modules..."
make modules_install
echo "Creating patched image for B3 (caches off, DTB appended)..."
pushd arch/arm/boot
# per https://lists.debian.org/debian-boot/2012/08/msg00804.html
echo -n -e \\x11\\x3f\\x3f\\xee >  cache_head_patch
echo -n -e \\x01\\x35\\xc3\\xe3 >> cache_head_patch
echo -n -e \\x11\\x3f\\x2f\\xee >> cache_head_patch
echo -n -e \\x00\\x30\\xa0\\xe3 >> cache_head_patch
echo -n -e \\x17\\x3f\\x07\\xee >> cache_head_patch
cat cache_head_patch zImage dts/kirkwood-b3.dtb > zImage-dts-appended
rm cache_head_patch
mkimage -A arm -O linux -T kernel -C none -a 0x00008000 -e 0x00008000 \
  -n "Gentoo ARM: ${KNAME}" -d zImage-dts-appended ../../../uImage
echo "Copying image to /boot/boot/uImage..."
popd
mkdir -p "/boot/boot"
# backup old versions if present
if [ -s /boot/boot/uImage ]; then
    mv /boot/boot/uImage /boot/boot/uImage.old
fi
if [ -s /boot/boot/config ]; then
    mv /boot/boot/config /boot/boot/config.old
fi
cp uImage /boot/boot/uImage
cp .config /boot/boot/config
echo "Syncing filesystems, please wait..."
sync
if ((DIDMOUNT==1)); then
    echo "Unmounting /boot..."
    umount /boot
fi # otherwise, leave as we found it (i.e., mounted)
echo "All done!"
