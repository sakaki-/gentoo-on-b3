# gentoo-on-b3

Bootable live-USB of Gentoo Linux for the Excito B3 miniserver, with Linux 3.15.9

## Description

<img src="https://wiki.gentoo.org/images/0/03/Excito_b3.jpg" alt="Excito B3" width="250px" align="right"/>
This project contains a bootable, live-USB image for the Excito B3 miniserver. You can use it as a rescue disk, to play with Gentoo Linux, or as the starting point to install Gentoo Linux on your B3's main hard drive. You can even use it on a diskless B3. No soldering, compilation, or [U-Boot](http://www.denx.de/wiki/U-Boot/WebHome) flashing is required! You can run it without harming your B3's existing software; however, any changes you make while running the system *will* be saved to the USB (i.e., there is persistence).

The kernel used in the image is **3.15.9** from the mainline, with the necessary code to switch off the L2 cache (per [this link](https://lists.debian.org/debian-boot/2012/08/msg00804.html)) prepended, and the kirkwood-b3 device tree blob appended. The `.config` used for the kernel may be found [here](https://github.com/sakaki-/gentoo-on-b3/blob/master/configs/b3_live_usb_config) in the git archive).

The images may be downloaded from the links below (or via `wget`, per the following instructions). Most people will want to use the `genb3img.xz` variant - the diskless version should *only* be used if you have no drive installed in your B3; it will fail to boot on a standard system (and vice versa).

Variant | Image | Digital Signature
:--- | ---: | ---:
B3 with Internal Drive | [genb3img.zx](https://github.com/sakaki-/gentoo-on-b3/releases/download/1.0.0/genb3img.xz) | [genb3img.zx.asc](https://github.com/sakaki-/gentoo-on-b3/releases/download/1.0.0/genb3img.xz.asc)
Diskless B3 | [genb3disklessimg.zx](https://github.com/sakaki-/gentoo-on-b3/releases/download/1.0.0/genb3disklessimg.xz) | [genb3disklessimg.zx.asc](https://github.com/sakaki-/gentoo-on-b3/releases/download/1.0.0/genb3disklessimg.xz.asc)

> Please read the instructions below before proceeding. Also please note that these images are provided 'as is' and without warranty.

## Prerequisites

To try this out, you will need:
* A USB key of at least 4GB capacity. Unfortunately, not all USB keys work with the version of [U-Boot](http://www.denx.de/wiki/U-Boot/WebHome) on the B3 (2010.06 on my device). I have tested it successfully with SanDisk Cruzer 4GB and 8GB USB keys, but some larger devices (e.g. 32GB Verbatim keys) do not work.
* An Excito B3 (obviously!). If it has an internal hard drive (i.e., it runs the standard Excito software), use the `genb3img.xz` image; if using a diskless chassis, use the `genb3disklessimg.xz` instead.
* A PC to decompress the appropriate image and write it to the USB key. This is most easily done on a Linux machine of some sort, but tools are also available for Windows (see [here](http://tukaani.org/xz/) and [here](http://sourceforge.net/projects/win32diskimager/), for example). In the instructions below I'm going to assume you're using Linux.

## Downloading and Writing the Image

On your Linux box, issue:
```
# wget -c https://github.com/sakaki-/gentoo-on-b3/releases/download/1.0.0/genb3img.xz
# wget -c https://github.com/sakaki-/gentoo-on-b3/releases/download/1.0.0/genb3img.xz.asc
```
to fetch the compressed disk image file (245MiB) and its signature.
> If you want the 'diskless' variant (because you have no internal hard drive in your B3), use:
```
# wget -c https://github.com/sakaki-/gentoo-on-b3/releases/download/1.0.0/genb3disklessimg.xz
# wget -c https://github.com/sakaki-/gentoo-on-b3/releases/download/1.0.0/genb3disklessimg.xz.asc
```
instead.

Next, if you like, verify the image using `gpg` (this step is optional):
```
# gpg --keyserver pool.sks-keyservers.net --recv-key DDE76CEA
# gpg --verify genb3img.xz.asc genb3img.xz
```
> If you downloaded the 'diskless' image, use:
```
# gpg --keyserver pool.sks-keyservers.net --recv-key DDE76CEA
# gpg --verify genb3disklessimg.xz.asc genb3disklessimg.xz
```
instead.

Assuming that reports 'Good signature', you can proceed.

Next, insert (into your Linux box) the USB key on which you want to install the image, and determine its device path (this will be something like `/dev/sdb`, `/dev/sdc` etc.; the actual path will depend on your system, you can use the `lsblk` tool to help you). Unmount any existing partitions of the USB key that may have automounted (using `umount`). Then issue:

> **Warning** - this will *destroy* all existing data on the target drive, so please double-check that you have the path correct!

```
# xzcat genb3img.xz > /dev/sdX && sync
```
> If you downloaded the 'diskless' image, use:
```
# xzcat genb3disklessimg.xz > /dev/sdX && sync
```
instead.

Substitute the actual USB key device path, for example `/dev/sdc`, for `/dev/sdX` in the above command. Make sure to reference the device, **not** a partition within it (so e.g., `/dev/sdc` and not `/dev/sdc1`; `/dev/sdd` and not `/dev/sdd1` etc.)

The write may take some time, due to the decompression. It should exit cleanly when done - if you get a message saying 'No space left on device', then your USB key is too small for the image, and you should try again with a larger capacity one.

## Specifying Required Network Settings

The Gentoo system on the image will setup the `eth0` network interface on boot (this uses the **wan** Ethernet port on the B3). However, before networking is started, it will attempt to read two files from the first partition of the USB key, namely `/install/net` and `/install/resolv.conf`; if found, these will be used to *overwrite* the files `/etc/conf.d/net` and `/etc/resolv.conf` on the USB root (in the USB key's second partition). Therefore, you can edit these two files to specify settings appropriate for your network.

In the image, `/install/net` initially contains:
> 
```
# static setup for eth0 (wan Ethernet port)
# this will be automatically brought up on boot
# edit the below to match your system
config_eth0="192.168.1.123 netmask 255.255.255.0 brd 192.168.1.255"
routes_eth0="default via 192.168.1.254"
# dynamic setup for eth1 (lan Ethernet port)
# this is not automatically started on boot
config_eth1="dhcp"
```

and `/install/resolv.conf` is:
> 
```
# use Google public DNS, as a sensible fallback
# modify this to match your system
nameserver 8.8.8.8
```

That is, as shipped, the Gentoo system will attempt to bring up the eth0 (**wan**) Ethernet interface, with a fixed address of 192.168.1.123, netmask 255.255.255.0, broadcast address 192.168.1.255 and gateway 192.168.1.254, using Google's DNS nameserver at 8.8.8.8. If these settings are not appropriate for your network, edit these files as required (note that you will have to specify a fixed address at this stage; later, when you are logged into the system, you can configure DHCP etc. if desired). The first USB partition is formatted `fat16` and so the edits can be made on any Windows box; or, if using Linux:
```
# mkdir /tmp/mntusb
# mount -v /dev/sdX1 /tmp/mntusb
# nano -w /tmp/mntusb/install/net
  <make changes as needed, and save>
# nano -w /tmp/mntusb/install/resolv.conf
  <make changes as needed, and save>
# sync
# umount -v /tmp/mntusb
```
Obviously, substitute the appropriate path for `/dev/sdX1` in the above. If your USB key is currently on `/dev/sdc`, you'd use `/dev/sdc1`; if it is on `/dev/sdd`, you'd use `/dev/sdd1`, etc.

All done, you are now ready to try booting your B3!

## Booting!

Begin with your B3 powered off and the power cable removed. Insert the USB key into either of the USB slots on the back of the B3, and make sure the other USB slot is unoccupied. Connect the B3 to your local network using the **wan** Ethernet port. Then, *while holding down the button on the back of the B3*, apply power (insert the power cable). After two seconds or so, release the button. If all is well, the B3 should boot the kernel off of the USB key (rather than the internal drive), and then proceed to mount the root partition (also from the USB key) and start Gentoo. This will all take about 40 seconds or so. The LED on the front of the B3 should first turn green, then turn off for about 20 seconds, and then turn green again as Gentoo comes up.

## Connecting to the B3

Once booted, you can log into the B3 from any other machine on your subnet (the root password is **gentoob3**). Issue:
```
> ssh root@192.168.1.123
The authenticity of host '192.168.1.123 (192.168.1.123)' can't be established.
ED25519 key fingerprint is 0c:b5:1c:66:19:8a:dc:81:0e:dc:1c:f5:25:57:7e:66.
Are you sure you want to continue connecting (yes/no)? <type yes and press Enter>
Warning: Permanently added '192.168.1.123' (ED25519) to the list of known hosts.
Password: <type gentoob3 and press Enter>
b3 ~ # 
```
and you're in! Obviously, substitute the correct network address for your b3 in the command above (if you changed it in `/install/net`, earlier). Also, note that you may receive a different fingerprint type, depending on what your `ssh` client supports. The `ssh` host key fingerprints on the image are as follows:
> 
```
1024 0a:39:60:54:ec:8c:7c:a0:3b:ab:74:f1:f9:b9:dd:dc  root@b3 (DSA)
256 0c:b5:1c:66:19:8a:dc:81:0e:dc:1c:f5:25:57:7e:66  root@b3 (ED25519)
2048 a9:0c:8c:6e:57:bd:0c:a5:64:ef:47:94:40:c2:35:81  root@b3 (RSA)
```

If you have previously connected to a *different* machine with the *same* IP address as your B3 via `ssh` from the client PC, you may need to delete its host fingerprint (from `~/.ssh/known_hosts` on the PC) before `ssh` will allow you to connect.

## Using Gentoo

The supplied image contains a fully-configured Gentoo system (*not* simply a [minimal install](https://www.gentoo.org/doc/en/handbook/handbook-amd64.xml?part=1&chap=2#doc_chap2) or [stage 3](https://www.gentoo.org/doc/en/handbook/handbook-amd64.xml?part=1&chap=5#doc_chap2)), with a complete Portage tree already downloaded, so you can immediately perform `emerge` operations (Gentoo's equivalent of `apt-get`) etc. Be aware that, as shipped, it uses UK locale settings and timezone; however, these are easily changed if desired. See the [Gentoo Handbook](https://www.gentoo.org/doc/en/handbook/handbook-amd64.xml?part=1&chap=6#doc_chap4) for details.

The image has the following packages already in its `@world` set:
> 
```
app-admin/logrotate
app-admin/syslog-ng
app-misc/screen
app-portage/eix
app-portage/euses
app-portage/gentoolkit
app-portage/mirrorselect
dev-embedded/u-boot-tools
net-misc/dhcpcd
net-misc/netifrc
net-wireless/iw
net-wireless/wireless-tools
sys-apps/mlocate
sys-apps/pciutils
sys-fs/dosfstools
sys-kernel/gentoo-sources:3.15.9
sys-process/cronie
```

plus of course the normal Gentoo `@system` set of tools.

It is based on the 5 June 2014 stage 3 release and minimal install system from Gentoo (armv5tel).

The drivers for WiFi (if you have the hardware on your B3) *are* present, but configuration of WiFi in master mode is beyond the scope of this short write up. The relevant network service (`net.wlp1s0`) has been created on the image, but is not setup to run on boot. Similarly, the **lan** port (`eth1`) interface service exists on the image (`net.eth1`), but is also not setup to run on boot. Feel free to configure these as desired; see [this section](https://www.gentoo.org/doc/en/handbook/handbook-amd64.xml?part=1&chap=3#doc_chap3) of the Gentoo Handbook for details.

Once you have networking set up as you like it, you can issue:
```
b3 ~ # rc-update del copynetsetup default 
```
to prevent them being overwritten again next by the files in the first USB partition, next time you boot.

When you are done using your Gentoo system, you can simply issue:
```
b3 ~ # reboot
```
and your machine will cleanly restart back into your existing (Excito) system off the hard drive. At this point, you can remove the USB key if you like. You can then, at any later time, simply repeat the 'power up with USB key inserted and button pressed' process to come back into Gentoo - any changes you made will still be present on the USB key.

Also, please note that there is no handler bound to the rear-button press events in the shipped system, so if you want to power off cleanly, issue: 
```
b3 ~ # shutdown -P now
```
Wait a few seconds after the green LED turns off before physically removing power.

Have fun! ^-^

## Miscellaneous Points

* The specific B3 devices (LEDs, buzzer, rear button etc.) are now described by the file `arch/arm/boot/dts/kirkwood-b3.dts` in the main kernel source directory (and included in the git archive too, for reference). You can see an example of using the defined devices in `/etc/init.d/bootled`, which turns on the green LED as Gentoo starts up, and off again on shutdown (this replaces the previous [approach](http://wiki.excito.org/wiki/index.php/Let_your_B3_beep_and_change_the_LED_color), which required an Excito-patched kernel).
* The live USB works because the B3's firmware boot loader will automatically try to run a file called `/install/install.itb` from the first partition of the USB drive when the system is powered up with the rear button depressed. In the provided image, we have placed a bootable kernel in that location, with an internal command line set to `root=/dev/sdb2 rootfstype=ext4 rootdelay=5 console=ttyS0,115200n8 earlyprintk`. (The 'diskless' variant uses a command line of `root=/dev/sda2 rootfstype=ext4 rootdelay=5 console=ttyS0,115200n8 earlyprintk`.) Despite the name, no 'installation' takes place, of course!
* If you have a USB key larger than the minimum 4GB, after writing the image you can easily extend the size of the second partition (using `fdisk` and `resize2fs`), so you have more space to work in. See [these instructions](http://geekpeek.net/resize-filesystem-fdisk-resize2fs/), for example.

## Installing Gentoo on your B3's Internal Drive (Optional)

If you like Gentoo, and want to set it up permanently on the B3's internal hard drive, you can do so easily (it takes less than 5 minutes). The full process is described below. (Note, this is strictly optional, you can simply run Gentoo from the USB key, if you are just experimenting, or using it as a rescue system.)

> **Warning** - the below process will wipe all existing software and data from your internal drive, so be sure to back that up first, before proceeding.

OK, first, boot into the image and then connect to your B3 via `ssh`, as described above. Then, configure the partition table on your hard drive, as described below (**warning** - this will delete all data and software on there, including your existing Excito system, so only proceed if you are sure). We'll make three partitions, for boot, swap and root (feel free to adopt a different scheme if you like; however, note that you will have to recompile your kernel unless targeting a `root` on `/dev/sda3`):
```
b3 ~ # fdisk /dev/sda
<press o and Enter (to create a new disk label)>
<press n and Enter (to create a new partition)>
<press Enter (to make a primary partition)>
<press Enter (to define partition 1)>
<press Enter (to accept the default start location)>
<type +32M and press Enter (to make a 32MiB sector, for boot)>
<type a and press Enter (to turn the boot flag on)>
<press n and Enter (to create a new partition)>
<press Enter (to make a primary partition)>
<press Enter (to define partition 2)>
<press Enter (to accept the default start location)>
<type +1G and press Enter (to make a 1GiB sector, for swap)>
<type t and press Enter (to change the sector type)>
<press Enter (to accept changing partition 2's type)>
<type 82 and press Enter (to set the type as swap)>
<type n and press Enter (to create a new partition)>
<press Enter (to make a primary partition)>
<press Enter (to define partition 3)>
<press Enter (to accept the default start location)>
<press Enter (to use all remaining space on the drive)>
<type p and press Enter (to review the partition table)>
<type w and press Enter (to write the table and exit)>
```

Next, format the partitions (NB, do **not** use `ext4` for the boot partition (`/dev/sda1`), as U-Boot will not be able to read it):
```
b3 ~ # mkfs.ext3 /dev/sda1
b3 ~ # mkswap /dev/sda2
b3 ~ # mkfs.ext4 /dev/sda3
```

Now, we need to copy the necessary system information. I have provided a second version of the kernel (in `root`'s home directory) that looks for its `root` partition on `/dev/sda3` (but is otherwise identical to the one on the USB key you booted off), so you need to copy that across:
```
b3 ~ # mkdir /mnt/{sdaboot,sdaroot}
b3 ~ # mount /boot
b3 ~ # mount /dev/sda1 /mnt/sdaboot
b3 ~ # mount /dev/sda3 /mnt/sdaroot
b3 ~ # mkdir /mnt/sdaboot/boot
b3 ~ # cp /root/root-on-sda3-kernel/uImage /mnt/sdaboot/boot/
```
Note that this kernel will be booted *without* the button pressed down, so it needs to live in the special path `/boot/uImage` on the first sector (which is where we just copied it to, above).

Next, we'll set up the `root` partition itself. The process below isn't quite what your mother would recommend ^-^, but it gets the job done (the first line may take some time to complete):
```
b3 ~ # cp -ax /bin /dev /etc /lib /root /sbin  /tmp /usr /var /mnt/sdaroot/
b3 ~ # mkdir /mnt/sdaroot/{boot,home,media,mnt,opt,proc,run,sys}
```

Since we simply copied over the `/etc/fstab` file, it will be wrong; a valid copy (for the internal drive) is present in `root`'s home directory on the USB image. Copy it over now:
```
b3 ~ # cp /root/fstab-on-b3 /mnt/sdaroot/etc/fstab
```
Finally, `sync` the filesystem, and unmount:
```
b3 ~ # sync
b3 ~ # umount -l /boot /mnt/{sdaboot,sdaroot}
b3 ~ # rmdir /mnt/{sdaboot,sdaroot}
```

That's it! You can now try rebooting your new system (it will have the same initial network settings as the USB version, since we've just copied them over). Issue:
```
b3 ~ # reboot
```
And let the system shut down and come back up. **Don't** press the B3's back-panel button this time. The system should boot directly off the hard drive. You can now remove the USB key, if you like, as it's no longer needed. Wait 30 seconds or so, then from your PC on the same subnet issue:
```
> ssh root@192.168.1.123
Password: <type gentoob3 and press Enter>
b3 ~ # 
```
Of course, use whatever IP address you assigned earlier, rather than `192.168.1.123` in the above. Also, if you changed root's password in the USB image, use that new password rather than `gentoob3` in the above.

Once logged in, feel free to configure your system as you like! Of course, if you're intending to use the B3 as an externally visible server, you should change the `ssh` host keys, change `root`'s password, install a firewall etc.

### Recompiling the Kernel (Optional)

If you'd like to compile a kernel on your new system, you can do so easily. Note that you **must** use at least version 3.15 of the kernel, as this is when the B3's device-tree information (the `arch/arm/boot/dts/kirkwood-b3.dts` file discussed earlier) was integrated into the mainline. You should also only do this from an installation on the B3's internal drive, as it requires quite a bit of disk space.

Suppose you wish to build 3.15.9 (the same version as supplied in the image), using the standard Gentoo-patched sources. Then you would issue:
```
b3 ~ # emerge =gentoo-sources-3.15.9
   (this will take some time to complete, depending on your network connection)
b3 ~ # cd /usr/src/linux
b3 linux # zcat /proc/config.gz > .config
b3 linux # make olddefconfig
   (you can make menuconfig etc. now if you want to change the .config)
b3 linux # /root/prep_arm_image_on_b3.sh
   (this will take some time! check out distcc if doing this regularly)
```
The `/root/prep_arm_image_on_b3.sh` script script (supplied) will build the kernel and modules (including L2-cache patch and device tree blob), and copy them to the appropriate directories for you. Once completed, when you restart, you'll be using your new kernel!

Of course, you can easily adapt the above process, if you wish to use Gentoo's hardened sources etc.

> Please note: if you rebuild the kernel in this way, the kernel's suffix will change from -b3 to -gentoo-b3; once rebooted, all the old modules at /lib/modules/3.15.9-b3 can safely be deleted, to save space.

## Feedback Welcome!

If you have any problems, questions or comments regarding this project, feel free to drop me a line! (sakaki@deciban.com)
