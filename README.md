# gentoo-on-b3

Bootable live-USB of Gentoo Linux for the Excito B3 miniserver, with Linux 4.0.1

## Description

<img src="https://raw.githubusercontent.com/sakaki-/resources/master/excito/b3/Excito_b3.jpg" alt="Excito B3" width="250px" align="right"/>
This project contains a bootable, live-USB image for the Excito B3 miniserver. You can use it as a rescue disk, to play with Gentoo Linux, or as the starting point to install Gentoo Linux on your B3's main hard drive. You can even use it on a diskless B3. No soldering, compilation, or [U-Boot](http://www.denx.de/wiki/U-Boot/WebHome) flashing is required! You can run it without harming your B3's existing software; however, any changes you make while running the system *will* be saved to the USB (i.e., there is persistence). A number of useful software packages (web server, mail server etc.) are included precompiled with the image (in their 'freshly emerged' configuration state), for convenience (with heartbleed, shellshock and Ghost fixes applied).

The kernel used in the image is **4.0.1** from gentoo-sources, with the necessary code to temporarily switch off the L2 cache in early boot (per [this link](https://lists.debian.org/debian-boot/2012/08/msg00804.html)) prepended, and the kirkwood-b3 device tree blob appended. The `.config` used for the kernel may be found [here](https://github.com/sakaki-/gentoo-on-b3/blob/master/configs/b3_live_usb_config) in the git archive.

> The kernel has also had [this patch](http://www.spinics.net/lists/arm-kernel/msg413993.html) applied, to ensure PCIe (and therefore, WiFi) works correctly on the B3. This patch is working its way through the usual pipeline towards release, but (at the time of writing) has not yet hit the mainline kernel. Please see [here](http://forum.mybubba.org/viewtopic.php?f=7&t=5768) for further details.

The image may be downloaded from the link below (or via `wget`, per the following instructions). (Incidentally, the image is now 'universal', and should work, without modification, whether your B3 has an internal hard drive fitted or not.)

Variant | Version | Image | Digital Signature
:--- | ---: | ---: | ---:
B3 with or without Internal Drive | 1.5.0 | [genb3img.xz](https://github.com/sakaki-/gentoo-on-b3/releases/download/1.5.0/genb3img.xz) | [genb3img.xz.asc](https://github.com/sakaki-/gentoo-on-b3/releases/download/1.5.0/genb3img.xz.asc)

The older images are still available [here](https://github.com/sakaki-/gentoo-on-b3/releases).

> Please read the instructions below before proceeding. Also please note that all images are provided 'as is' and without warranty.

## Prerequisites

To try this out, you will need:
* A USB key of at least 8GB capacity (the *compressed* (.xz) image is 356MiB, the *uncompressed* image is 14,813,184 (512 byte) sectors = 7,584,350,208 bytes). Unfortunately, not all USB keys work with the version of [U-Boot](http://www.denx.de/wiki/U-Boot/WebHome) on the B3 (2010.06 on my device). Most SanDisk and Lexar USB keys appear to work reliably, but others (e.g., Verbatim keys) will not boot properly. (You may find the list of known-good USB keys [in this post](http://forum.doozan.com/read.php?2,1915,page=1) useful.)
* An Excito B3 (obviously!). As of version 1.3.0, the *same* image will work both for the case where you have an internal hard drive in your B3 (the normal situation), *and* for the case where you are running a diskless B3 chassis.
* A PC to decompress the image and write it to the USB key (of course, you can also use your B3 for this, assuming it is currently running the standard Excito / Debian Squeeze system). This is most easily done on a Linux machine of some sort, but tools are also available for Windows (see [here](http://tukaani.org/xz/) and [here](http://sourceforge.net/projects/win32diskimager/), for example). In the instructions below I'm going to assume you're using Linux.

> Incidentally, I also have an [Arch Linux](https://www.archlinux.org/) live USB for the B3, available [here](https://github.com/sakaki-/archlinux-on-b3), and a Gentoo Linux live USB for the B2, available [here](https://github.com/sakaki-/gentoo-on-b2).

## Downloading and Writing the Image

On your Linux box, issue:
```
# wget -c https://github.com/sakaki-/gentoo-on-b3/releases/download/1.5.0/genb3img.xz
# wget -c https://github.com/sakaki-/gentoo-on-b3/releases/download/1.5.0/genb3img.xz.asc
```
to fetch the compressed disk image file (356MiB) and its signature.

Next, if you like, verify the image using `gpg` (this step is optional):
```
# gpg --keyserver pool.sks-keyservers.net --recv-key DDE76CEA
# gpg --verify genb3img.xz.asc genb3img.xz
```

Assuming that reports 'Good signature', you can proceed.

Next, insert (into your Linux box) the USB key on which you want to install the image, and determine its device path (this will be something like `/dev/sdb`, `/dev/sdc` etc.; the actual path will depend on your system, you can use the `lsblk` tool to help you). Unmount any existing partitions of the USB key that may have automounted (using `umount`). Then issue:

> **Warning** - this will *destroy* all existing data on the target drive, so please double-check that you have the path correct!

```
# xzcat genb3img.xz > /dev/sdX && sync
```

Substitute the actual USB key device path, for example `/dev/sdc`, for `/dev/sdX` in the above command. Make sure to reference the device, **not** a partition within it (so e.g., `/dev/sdc` and not `/dev/sdc1`; `/dev/sdd` and not `/dev/sdd1` etc.)

The above `xzcat` to the USB key will take some time, due to the decompression (it takes between 8 and 20 minutes on my machine, depending on the USB key used). It should exit cleanly when done - if you get a message saying 'No space left on device', then your USB key is too small for the image, and you should try again with a larger capacity one.

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

That is, as shipped, the Gentoo system will attempt to bring up the eth0 (**wan**) Ethernet interface, with a fixed address of 192.168.1.123, netmask 255.255.255.0, broadcast address 192.168.1.255 and gateway 192.168.1.254, using Google's DNS nameserver at 8.8.8.8. If these settings are not appropriate for your network, edit these files as required (note that you will have to specify a fixed address at this stage; later, when you are logged into the system, you can configure DHCP etc. if desired). The first USB partition is formatted `fat16` and so the edits can be made on any Windows box (any [modified line endings](https://danielmiessler.com/study/crlf/) will be fixed up automatically, when the files are copied across during boot); or, if using Linux:
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

Begin with your B3 powered off and the power cable removed. Insert the USB key into either of the USB slots on the back of the B3, and make sure the other USB slot is unoccupied. Connect the B3 to your local network using the **wan** Ethernet port. Then, *while holding down the button on the back of the B3*, apply power (insert the power cable). After two seconds or so, release the button. If all is well, the B3 should boot the kernel off of the USB key (rather than the internal drive), and then proceed to mount the root partition (also from the USB key) and start Gentoo. This will all take about 40 seconds or so. The LED on the front of the B3 should:

1. first, turn **green**, for a few seconds, as the kernel loads; then,
1. turn **purple** for about 20 seconds during early init; and finally,
1. turn **green** again as Gentoo comes up (enters [runlevel](https://en.wikipedia.org/wiki/Runlevel) 3).

> The image uses a solid green LED as its 'normal' state, so that you can easily tell at a glance whether your B3 is running an Excito/Debian system (blue LED) or a Gentoo one (green LED).

About 20 seconds after the LED turns green in step 3, above, you should be able to log in, via `ssh`, per the following instructions.

## Connecting to the B3

Once booted, you can log into the B3 from any other machine on your subnet (the root password is **gentoob3**). Issue:
```
$ ssh root@192.168.1.123
The authenticity of host '192.168.1.123 (192.168.1.123)' can't be established.
ED25519 key fingerprint is 0c:b5:1c:66:19:8a:dc:81:0e:dc:1c:f5:25:57:7e:66.
Are you sure you want to continue connecting (yes/no)? <type yes and press Enter>
Warning: Permanently added '192.168.1.123' (ED25519) to the list of known hosts.
Password: <type gentoob3 and press Enter>
b3 ~ # 
```
and you're in! Obviously, substitute the correct network address for your b3 in the command above (if you changed it in `/install/net`, earlier). You may receive a different fingerprint type, depending on what your `ssh` client supports. Also, please note that as of version 1.3.1, the `ssh` host keys are generated on first boot (for security), and so the fingerprint you get will be different from that shown above.

If you have previously connected to a *different* machine with the *same* IP address as your B3 via `ssh` from the client PC, you may need to delete its host fingerprint (from `~/.ssh/known_hosts` on the PC) before `ssh` will allow you to connect.

## Using Gentoo

The supplied image contains a fully-configured Gentoo system (*not* simply a [minimal install](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Media#Minimal_installation_CD) or [stage 3](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Media#What_are_stages_then.3F)), with a complete Portage tree already downloaded, so you can immediately perform `emerge` operations (Gentoo's equivalent of `apt-get`) etc. Be aware that, as shipped, it uses UK locale settings and timezone; however, these are easily changed if desired. See the [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base#Timezone) for details.

The full set of packages in the image may be viewed [here](https://github.com/sakaki-/gentoo-on-b3/blob/master/reference/installed-packages) (note that the version numbers shown in this list are Gentoo ebuilds, but they generally map 1-to-1 onto upstream package versions).

It is based on the 5 June 2014 stage 3 release and minimal install system from Gentoo (armv5tel), with all packages brought up to date against the Gentoo tree as of 10 Feb 2015. As such, heartbleed, shellshock and Ghost fixes have been applied.

The drivers for WiFi (if you have the hardware on your B3) *are* present, but configuration of WiFi in master mode (using hostapd) is beyond the scope of this short write up (see [here](http://nims11.wordpress.com/2012/04/27/hostapd-the-linux-way-to-create-virtual-wifi-access-point/) for some details). The relevant network service (`net.wlp1s0`) has been created on the image, but is not setup to run on boot. Similarly, the **lan** port (`eth1`) interface service exists on the image (`net.eth1`), but is also not setup to run on boot. Feel free to configure these as desired; see [this volume](https://wiki.gentoo.org/wiki/Handbook:AMD64#Gentoo_network_configuration) of the Gentoo Handbook for details.

Once you have networking set up as you like it, you can issue:
```
b3 ~ # rc-update del copynetsetup default 
```
to prevent them being overwritten again next by the files in the first USB partition, next time you boot.

When you are done using your Gentoo system, you can simply issue:
```
b3 ~ # reboot
```
and your machine will cleanly restart back into your existing (Excito) system off the hard drive. At this point, you can remove the USB key if you like. You can then, at any later time, simply repeat the 'power up with USB key inserted and button pressed' process to come back into Gentoo - any changes you made will still be present on the USB key. This makes for an easy way to migrate across gradually to Gentoo if you like, without having to disrupt your normal Excito Debian setup (which you can always just reboot back into at any time).

To power off cleanly (rather than rebooting), you have two options. First, as the image now includes Tor's [bubba-buttond](https://github.com/Excito/bubba-buttond) (courtesy of Gordon's [ebuild](https://github.com/gordonb3/bubba-overlay/tree/master/sys-power/bubba-buttond)), you can simply press the B3's rear button for around 5 seconds, then release it (just as you would on a regular Excito system). The front LED will turn from green to purple after around 20 seconds, then turn off once it is safe to physically remove the power cable.

Second, if you'd rather use the command line, you can issue: 
```
b3 ~ # poweroff-b3
```
which will have the same effect (and follow the same power-down LED sequence).

Have fun! ^-^

## Miscellaneous Points

* The specific B3 devices (LEDs, buzzer, rear button etc.) are now described by the file `arch/arm/boot/dts/kirkwood-b3.dts` in the main kernel source directory (and included in the [git archive too](https://github.com/sakaki-/gentoo-on-b3/blob/master/reference/kirkwood-b3.dts), for reference). You can see an example of using the defined devices in `/etc/init.d/bootled`, which turns on the green LED as Gentoo starts up, and back to purple again on shutdown (this replaces the previous [approach](http://wiki.mybubba.org/wiki/index.php?title=Let_your_B3_beep_and_change_the_LED_color), which required an Excito-patched kernel). Note that the USB image uses a slightly patched version of the DTS (available [here](https://github.com/sakaki-/gentoo-on-b3/blob/master/reference/kirkwood-b3-live-usb.dts)), to ensure that the front LED is purple during early boot.
* The live USB works because the B3's firmware boot loader will automatically try to run a file called `/install/install.itb` from the first partition of the USB drive when the system is powered up with the rear button depressed. In the provided image, we have placed bootable kernel uImage in that location, with an internal command line set to `root=PARTUUID=05A8FC63-03 rootfstype=ext4 rootdelay=5 console=ttyS0,115200n8 earlyprintk`. Despite the name, no 'installation' takes place, of course!
* The image is subscribed to the following overlays:
  * [`sakaki-tools-lite`](https://github.com/sakaki-/sakaki-tools-lite): this provides the tools `showem-lite` ([source](https://github.com/sakaki-/showem-lite), [manpage](https://github.com/sakaki-/gentoo-on-b3/raw/master/reference/showem-lite.pdf)) and `genup-lite` ([source](https://github.com/sakaki-/genup-lite), [manpage](https://github.com/sakaki-/gentoo-on-b3/raw/master/reference/genup-lite.pdf)).
  * [`gentoo-b3`](https://github.com/sakaki-/gentoo-b3-overlay): this provides the `b3-init-scripts` package ([source](https://github.com/sakaki-/gentoo-b3-overlay/tree/master/sys-apps/b3-init-scripts/files)), a modern version of the `lzo` package ([upstream](http://www.oberhumer.com/opensource/lzo/download/); required because of an [alignment bug](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=757037#32)), and the `buildkernel-b3` tool ([source](https://github.com/sakaki-/buildkernel-b3), [manpage](https://github.com/sakaki-/gentoo-on-b3/raw/master/reference/buildkernel-b3.pdf)).
  * [`bubba`](https://github.com/gordonb3/bubba-overlay): this overlay (provided by Gordon) provides the `bubba-buttond` [ebuild](https://github.com/gordonb3/bubba-overlay/tree/master/sys-power/bubba-buttond) ([upstream](https://github.com/Excito/bubba-buttond)). It also provides ebuilds for the Logitech Media Server and Domoticz; these have not been installed in the image, but you can easily `emerge` them if you like (most of the prerequisites have been installed on the image already).
* The image now includes a 1GiB swap partition, and (since a minimum 8GB key is now required, rather than 4GB) also has sufficient space in its root partition to e.g., perform a kernel compilation, should you so desire.
* If you have a USB key larger than the minimum 8GB, after writing the image you can easily extend the size of the second partition (using `fdisk` and `resize2fs`), so you have more space to work in. See [these instructions](http://geekpeek.net/resize-filesystem-fdisk-resize2fs/), for example.

## <a name="hdd_install">Installing Gentoo on your B3's Internal Drive (Optional)

If you like Gentoo, and want to set it up permanently on the B3's internal hard drive, you can do so easily (it takes less than 5 minutes). The full process is described below. (Note, this is strictly optional, you can simply run Gentoo from the USB key, if you are just experimenting, or using it as a rescue system.)

> **Warning** - the below process will wipe all existing software and data from your internal drive, so be sure to back that up first, before proceeding. It will set up:
* /dev/sda1 as a 64MiB boot partition, and format it `ext3`;
* /dev/sda2 as a 1GiB swap partition;
* /dev/sda3 as a root partition using the rest of the drive, and format it `ext4`.

> Note also that the script [`/root/install_on_sda.sh`](https://github.com/sakaki-/gentoo-on-b3/blob/master/reference/install_on_sda.sh) will install using a DOS partition table (max 2TiB); if you'd rather use GPT, then use [`/root/install_on_sda_gpt.sh`](https://github.com/sakaki-/gentoo-on-b3/blob/master/reference/install_on_sda_gpt.sh) instead. [All B3s](http://forum.mybubba.org/viewtopic.php?f=7&t=5755) can boot from a GPT-partitioned drive; however, please note that if your HDD has a capacity > 2TiB, then only those B3s with a [relatively modern](http://forum.mybubba.org/viewtopic.php?f=9&t=5745) U-Boot will work correctly. The DOS partition table version should work for any size drive (but will be constrained to a maximum of 2TiB).

OK, first, boot into the image and then connect to your B3 via `ssh`, as described above. Then, (as of version 1.4.0) you can simply run the supplied script to install onto your hard drive:
```
b3 ~ # /root/install_on_sda.sh
Install Gentoo -> /dev/sda (B3's internal HDD)

WARNING - will delete anything currently on HDD
(including any existing Excito Debian system)
Please make sure you have adequate backups before proceeding

Type (upper case) INSTALL and press Enter to continue
Any other entry quits without installing: <type INSTALL and press Enter, to proceed>
Installing: check '/var/log/gentoo_install.log' in case of errors
Step 1 of 5: creating partition table on /dev/sda...
Step 2 of 5: formatting partitions on /dev/sda...
Step 3 of 5: mounting boot and root partitions from /dev/sda...
Step 4 of 5: copying system and bootfiles (please be patient)...
Step 5 of 5: syncing filesystems and unmounting...
All done! You can reboot into your new system now.
```

That's it! You can now try rebooting your new system (it will have the same initial network settings as the USB version, since we've just copied them over). Issue:
```
b3 ~ # reboot
```
And let the system shut down and come back up. **Don't** press the B3's back-panel button this time. The system should boot directly off the hard drive. You can now remove the USB key, if you like, as it's no longer needed. Wait 40 seconds or so, then from your PC on the same subnet issue:
```
> ssh root@192.168.1.123
Password: <type gentoob3 and press Enter>
b3 ~ # 
```
Of course, use whatever IP address you assigned earlier, rather than `192.168.1.123` in the above. Also, if you changed root's password in the USB image, use that new password rather than `gentoob3` in the above.

Once logged in, feel free to configure your system as you like! Of course, if you're intending to use the B3 as an externally visible server, you should take the usual precautions, such as changing `root`'s password, configuring the firewall, possibly [changing the `ssh` host keys](https://missingm.co/2013/07/identical-droplets-in-the-digitalocean-regenerate-your-ubuntu-ssh-host-keys-now/#how-to-generate-new-host-keys-on-an-existing-server), etc.

### Recompiling the Kernel (Optional)

If you'd like to compile a kernel on your new system, you can do so easily (even if still running from the USB - it has sufficient free space). Note that you **must** use at least version 3.15 of the kernel, as this is when the B3's device-tree information (the `arch/arm/boot/dts/kirkwood-b3.dts` file discussed earlier) was integrated into the mainline.

Suppose you wish to build the most modern version available using the standard Gentoo-patched sources. Then you would issue:
```
b3 ~ # emerge --ask --verbose gentoo-sources
   (confirm when prompted; this will take some time to complete, depending on your network connection)
b3 ~ # eselect kernel list
   (this will show a numbered list of available kernels)
b3 ~ # eselect kernel set 1
   (replace '1' in the above command with the number of the desired kernel from the list)
b3 ~ # cd /usr/src/linux
```
Next, if you are running Gentoo from your B3's internal hard drive, issue:
```
b3 linux # buildkernel-b3 --custom-dts=/root/kirkwood-b3-live-usb.dts --menuconfig
```
otherwise, if still running from the USB, issue:
```
b3 linux # buildkernel-b3 --custom-dts=/root/kirkwood-b3-live-usb.dts --usb --menuconfig
```
The `buildkernel-b3` script (supplied) will build the kernel and modules (including L2-cache patch and device tree blob), and copy them to the appropriate directories for you (see its manpage [here](https://github.com/sakaki-/gentoo-on-b3/raw/master/reference/buildkernel-b3.pdf)). It will, by default, use your running kernel's config as a basis, and (if you specify `--menuconfig` when invoking it, as above), offer you the chance to modify the kernel configuration using the standard editor. Once completed, when you restart, you'll be using your new kernel!

> Note - the command above uses the `--custom-dts` option to `buildkernel-b3`, so that we can reference the slightly modified device tree source (provided). This has been changed to turn the front LED purple during early boot. If you don't use it, the LED will turn off for around 20 seconds during the boot process. The underlying patch has been [submitted upstream](http://forum.mybubba.org/viewtopic.php?f=7&t=5680&start=15#p26825), so should hit the mainline kernel at some point.

Of course, you can easily adapt the above process, if you wish to use Gentoo's hardened sources etc.

> Please note that there was a major re-organization of the Marvell architecture in version 3.17 of the kernel, with [mach-kirkwood being removed](https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=ba364fc752daeded072a5ef31e43b84cb1f9e5fd). As a result, the required format of the config file changed signficantly (for the B3), such that a simple `make olddefconfig` on a < 3.17 kernel config will no longer generate a bootable kernel. As such, if building a >= 3.17 kernel, you should use the [v1.5.0 configs](https://github.com/sakaki-/gentoo-on-b3/tree/1.5.0/configs) from this project as a basis (as these have the new schema); however, if building 3.15 <= x < 3.17, use the [v1.1.0 configs](https://github.com/sakaki-/gentoo-on-b3/tree/1.1.0/configs) instead. Versions < 3.15 do not have device-tree support for the B3, and should not be used.

It is also possible to cross-compile a kernel on your (Gentoo) PC, which is *much* faster than doing it directly on the B3. Please see the instructions at the tail of this document.

> Alternatively, if you set up `distcc` (also covered in the instructions below), an invocation of `buildkernel-b3` on your B3 will *automatically* offload kernel compilation workload to your PC. However, if you do use `distcc` in this way, be aware that not all kernel files can be successfully built in this manner; a small number (particularly, at the start of the kernel build) may fall back to using local compilation. This is normal, and the vast majority of files *will* distribute OK.

### Keeping Your Gentoo System Up-To-Date

You can update your system at any time (whether you are running Gentoo from USB or the B3's internal drive). As there are quite a few steps involved to do this correctly on Gentoo, I have provided a convenience script, `genup-lite` to do this as part of the image. So, to update your system, simply issue:
```
b3 ~ # genup-lite
   (this will take some time to complete)
```
This is loosely equivalent to `apt-get update && apt-get upgrade` on Debian. See the [manpage](https://github.com/sakaki-/gentoo-on-b3/raw/master/reference/genup-lite.pdf) for full details of the process followed, and the options available for the command.

> **Erratum** - if you are using version 1.3.1 or 1.3.0 of the image, you need to edit the file `/etc/portage/package.accept_keywords`, and change the line citing the `bubba` repository so it reads:
```
*/*::bubba ~arm
```
If you do not, `genup-lite` may fail, trying to pull in `cryptodev-linux` when `openssl` is next updated. Users of versions >= 1.3.2 need take no action.

Note that because Gentoo is a source-based distribution, and the B3 is not a particularly fast machine, updating may take a number of hours, if many packages have changed. However, `genup-lite` will automatically take advantage of distributed cross-compiling, using `distcc`, if you have that set up (see the next section for details).

When the update has completed, if promped to do so by `genup-lite`, then issue:
```
b3 ~ # dispatch-conf
```
to deal with any config file clashes that may have been introduced by the upgrade process.

> Note that the **kernel** build process for Gentoo is separate (see the previous section for details).

For more information about Gentoo's package management, see [my notes here](https://wiki.gentoo.org/wiki/Sakaki's_EFI_Install_Guide/Installing_the_Gentoo_Stage_3_Files#Gentoo.2C_Portage.2C_Ebuilds_and_emerge_.28Background_Reading.29).

> You may also find it useful to keep an eye on the 'Development' forum at [mybubba.org](http://forum.mybubba.org/index.php), as I occasionally post information about this live-USB there.

## Have your Gentoo PC Do the Heavy Lifting!

The B3 does not have a particularly fast processor when compared to a modern PC. While this is fine when running the device in day-to-day mode (as a mailserver, for example), it does pose a bit of an issue with a source-based distribution like Gentoo, where you must compile packages to upgrade them. Everything works, but an upgrade of a significant package, like `boost`, can take many hours, which soon gets tiresome.

However, there is a solution to this, and it is not as scary as it sounds - leverage the power of your PC (assuming it too is running Gentoo Linux) as a cross-compilation host!

For example, you can cross-compile kernels for your B3 on your PC very quickly (around 5-15 minutes from scratch), by using Gentoo's [`crossdev`](http://gentoo-en.vfose.ru/wiki/Crossdev) tool. See my full instructions [here](https://github.com/sakaki-/gentoo-on-b3/wiki/Set-Up-Your-Gentoo-PC-for-Cross-Compilation-with-crossdev) and [here](https://github.com/sakaki-/gentoo-on-b3/wiki/Build-a-B3-Kernel-on-your-crossdev-PC) on this project's [wiki](https://github.com/sakaki-/gentoo-on-b3/wiki).

Should you setup crossdev on your PC in this manner, you can then take things a step further, by leveraging your PC as a `distcc` server (instructions [here](https://github.com/sakaki-/gentoo-on-b3/wiki/Set-Up-Your-crossdev-PC-for-Distributed-Compilation-with-distcc) on the wiki). Then, with just some simple configuration changes on your B3 (see [these notes](https://github.com/sakaki-/gentoo-on-b3/wiki/Set-Up-Your-B3-as-a-distcc-Client)), you can distribute C/C++ compilation (and header preprocessing) to your remote machine, which makes system updates a *lot* quicker (and the provided tools [`genup-lite`](https://github.com/sakaki-/genup-lite) and [`buildkernel-b3`](https://github.com/sakaki-/buildkernel-b3) will automatically take advantage of this distributed compilation ability, if available).

## Feedback Welcome!

If you have any problems, questions or comments regarding this project, feel free to drop me a line! (sakaki@deciban.com)
