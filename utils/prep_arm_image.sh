#!/bin/bash
# Prepare B3 image, switching off cache, and appending DTB; also
# creates and copies over modules.
# Execute in top-level kernel directory.
# You must have mounted /mnt/b3boot and /mnt/b3root before running.
# Copyright (c) 2014 sakaki <sakaki@deciban.com>
# License: GPL 3.0+
# NO WARRANTY
set -e
set -u
die() { cat <<< "$@" 1>&2; exit 1; }
NUMTHREADS=$(( $(grep -E 'processor\s+:' /proc/cpuinfo | wc -l) + 1 ))
KNAME="$(basename "${PWD}")"
KNAME="${KNAME/linux-/Linux }"

for M in "/mnt/b3boot" "/mnt/b3root"; do
    if ! grep -qs "${M}" /proc/mounts; then
        die "You must mount ${M} before running this script."
    fi
done
echo "Compiling kernel (${KNAME})..."
make -j${NUMTHREADS} ARCH=arm CROSS_COMPILE=armv5tel-softfloat-linux-gnueabi- \
  zImage
echo "Compiling DTB..."
make ARCH=arm CROSS_COMPILE=armv5tel-softfloat-linux-gnueabi- kirkwood-b3.dtb
echo "Compiling modules..."
make -j${NUMTHREADS} ARCH=arm CROSS_COMPILE=armv5tel-softfloat-linux-gnueabi- \
  modules
echo "Copying modules to /mnt/b3root..."
make ARCH=arm CROSS_COMPILE=armv5tel-softfloat-linux-gnueabi- \
  INSTALL_MOD_PATH="/mnt/b3root/" modules_install
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
rm zImage-dts-appended
echo "Copying image to /mnt/b3boot/install/install.itb..."
popd
mkdir -p /mnt/b3boot/install
cp uImage /mnt/b3boot/install/install.itb
echo "Syncing filesystems, please wait..."
sync
echo "All done!"
echo "You can safely unmount /mnt/b3boot and /mnt/b3root now, and then"
echo "remove the USB key"
