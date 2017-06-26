# gentoo-on-b3

Bootable live-USB of Gentoo Linux for the Excito B3 miniserver, with weekly-autobuild binhost backing (inc. kernel)

## Description

<img src="https://raw.githubusercontent.com/sakaki-/resources/master/excito/b3/Excito_b3.jpg" alt="Excito B3" width="250px" align="right"/>

This project contains a bootable, live-USB image for the Excito B3 miniserver. You can use it as a rescue disk, to play with Gentoo Linux, or as the starting point to install Gentoo Linux on your B3's main hard drive. You can even use it on a diskless B3. No soldering, compilation, or [U-Boot](http://www.denx.de/wiki/U-Boot/WebHome) flashing is required! You can run it without harming your B3's existing software; however, any changes you make while running the system *will* be saved to the USB (i.e., there is persistence). A number of useful software packages (web server, mail server etc.) are included precompiled with the image (in their 'freshly emerged' configuration state), for convenience.

As of version 2.0.0:
* an "interstitial" kernel is now used during early boot, a strategy that has been succesfully used for a number of years now on my [archlinux-on-b3](https://github.com/sakaki-/archlinux-on-b3/) image. Under this approach, the B3's U-Boot loader actually starts a fixed-version kernel (the "interstitial kernel") which, together with its [initramfs](https://github.com/sakaki-/gentoo-on-b3/releases/tag/2.0.0#downloads), then acts as a second-stage bootloader for the kernel proper (chainloaded via `kexec`). This allows the "real" kernel to be distributed as a vanilla zImage, and also enables you to change the kernel command line easily (by editing the file `/boot/kexec.sh`), *without* having to flash any U-Boot variables;
* the current, weekly-autobuild [gentoo-b3-kernel](https://github.com/sakaki-/gentoo-b3-kernel) kernel is utilized as the "real" kernel, via the binary package [gentoo-b3-kernel-bin](https://github.com/sakaki-/gentoo-b3-overlay/tree/master/sys-kernel/gentoo-b3-kernel-bin). Accordingly, your kernel (and module set) will automatically be updated (along with all other packages on the system) whenever you issue `genup` (of which more [later](#genup); the initial kernel version shipped on the image is **4.11.6-gentoo-b3**, derived from [gentoo-sources](https://wiki.gentoo.org/wiki/Kernel/Overview#General_purpose:_gentoo-sources) and [this baseline config](https://github.com/sakaki-/gentoo-on-b3/blob/master/configs/b3_baseline_config);
* a [Gentoo binhost](https://wiki.gentoo.org/wiki/Binary_package_guide) (automatically updated weekly) has been provided (at https://isshoni.org/b3), to allow your B3 to perform fast updates via binary packages where possible, only falling back to local source-based compilation where necessary (using this facility is optional; it is activated by default in the live-USB, but instructions for turning it off are provided [below](#binhost_unsubscribe)). The binhost additionally provides an rsync mirror for the main `gentoo` repo (with [porthash](https://github.com/sakaki-/porthash) authentication), used to keep the B3's ebuild tree in lockstep; and
* a custom Gentoo profile, `gentoo-b3:default/linux/arm/13.0/armv5te/b3`, is provided, which supplies many of the default build settings, USE flags etc., required for Gentoo on the B3, keeping them also in lockstep with the binhost. You can view this profile (provided via the [gentoo-b3](https://github.com/sakaki-/gentoo-b3-overlay) overlay) [here](https://github.com/sakaki-/gentoo-b3-overlay/tree/master/profiles/targets/b3). 

The image may be downloaded from the link below (or via `wget`, per the following instructions). (Incidentally, the image is 'universal', and should work, without modification, whether your B3 has an internal hard drive fitted or not.)

Variant | Version | Image | Digital Signature
:--- | ---: | ---: | ---:
B3 with or without Internal Drive | 2.0.0 | [genb3img.xz](https://github.com/sakaki-/gentoo-on-b3/releases/download/2.0.0/genb3img.xz) | [genb3img.xz.asc](https://github.com/sakaki-/gentoo-on-b3/releases/download/2.0.0/genb3img.xz.asc)

The older images are still available (together with a short changelog) [here](https://github.com/sakaki-/gentoo-on-b3/releases).

> Please read the instructions below before proceeding. Also please note that all images are provided 'as is' and without warranty.

## Prerequisites

To try this out, you will need:
* A USB key of at least 8GB capacity (the *compressed* (.xz) image is 376MiB, the *uncompressed* image is 14,813,184 (512 byte) sectors = 7,584,350,208 bytes). Unfortunately, not all USB keys work with the version of [U-Boot](http://www.denx.de/wiki/U-Boot/WebHome) on the B3 (2010.06 on my device). Most SanDisk and Lexar USB keys appear to work reliably, but others (e.g., Verbatim keys) will not boot properly. (You may find the list of known-good USB keys [in this post](http://forum.doozan.com/read.php?2,1915,page=1) useful.)
* An Excito B3 (obviously!). As of version 1.3.0, the *same* image will work both for the case where you have an internal hard drive in your B3 (the normal situation), *and* for the case where you are running a diskless B3 chassis.
* A PC to decompress the image and write it to the USB key (of course, you can also use your B3 for this, assuming it is currently running the standard Excito / Debian Squeeze system). This is most easily done on a Linux machine of some sort, but tools are also available for Windows (see [here](http://tukaani.org/xz/) and [here](http://sourceforge.net/projects/win32diskimager/), for example). In the instructions below I'm going to assume you're using Linux.

> Incidentally, I also have an [Arch Linux](https://www.archlinux.org/) live USB for the B3, available [here](https://github.com/sakaki-/archlinux-on-b3), a [RedSleeve](https://en.wikipedia.org/wiki/RedSleeve) v7 live USB for the B3, available [here](https://github.com/sakaki-/redsleeve-on-b3), and a Gentoo Linux live USB for the B2, available [here](https://github.com/sakaki-/gentoo-on-b2).

## Downloading and Writing the Image

On your Linux box, issue:
```
# wget -c https://github.com/sakaki-/gentoo-on-b3/releases/download/2.0.0/genb3img.xz
# wget -c https://github.com/sakaki-/gentoo-on-b3/releases/download/2.0.0/genb3img.xz.asc
```
to fetch the compressed disk image file (376MiB) and its signature.

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

## Booting!

Begin with your B3 powered off and the power cable removed. Insert the USB key into either of the USB slots on the back of the B3, and make sure the other USB slot is unoccupied. Connect your B3 into your local network (or directly to your ADSL router, cable modem etc., if you wish) using the **wan** Ethernet port. Then, *while holding down the button on the back of the B3*, apply power (insert the power cable). After two seconds or so, release the button. If all is well, the B3 should boot the interstitial ("bootloader") kernel off of the USB key (rather than the internal drive), and then proceed to patch, load and `kexec` the [gentoo-b3-kernel](https://github.com/sakaki-/gentoo-b3-kernel), mount the root partition (also from the USB key) and start Gentoo. This will all take about 60 seconds or so. The LED on the front of the B3 should:

1. first, turn **green**, for about 20 seconds, and then briefly **purple**, as the interstitial kernel loads; then
1. turn **off** for about 10 seconds, as the ['real'](https://github.com/sakaki-/gentoo-b3-kernel) kernel is patched and loaded; then
1. turn **purple** again for about 20 seconds, as the real kernel boots, and then
1. turn **green** again as Gentoo comes up (enters [runlevel](https://en.wikipedia.org/wiki/Runlevel) 3).

About 60 seconds after the LED turns green in step 4, above, you should be able to log in, via `ssh`, per the following instructions.

> The image uses a solid green LED as its 'normal' state, so that you can easily tell at a glance whether your B3 is running an Excito/Debian system (blue LED) or a Gentoo one (green LED).

> Also, please note that if you have installed Gentoo Linux to your internal HDD (per the instructions given [later](#hdd_install)), and are booting from the HDD, that the front LED will be **purple**, not green-then-purple, throughout phase 1.

## Connecting to the B3

Once booted, you can log into the B3 as follows.

First, connect your client PC (or Mac etc.) to the **lan** Ethernet port of your B3 (you can use a regular Ethernet cable for this, the B3's ports are autosensing). Alternatively, if you have a WiFi enabled B3, you can connect to the "b3" WiFi network which should now be visible (the passphrase is **changeme**).

Then, on your client PC, issue:
```
$ ssh root@b3
The authenticity of host 'b3 (192.168.50.1)' can't be established.
ED25519 key fingerprint is 0c:b5:1c:66:19:8a:dc:81:0e:dc:1c:f5:25:57:7e:66.
Are you sure you want to continue connecting (yes/no)? <type yes and press Enter>
Warning: Permanently added 'b3,192.168.50.1' (ED25519) to the list of known hosts.
Password: <type gentoob3 and press Enter>
b3 ~ # 
```
and you're in! You may receive a different fingerprint type, depending on what your `ssh` client supports. Also, please note that as of version 1.3.1, the `ssh` host keys are generated on first boot (for security), and so the fingerprint you get will be different from that shown above.

> If you have trouble with `ssh root@b3`, you can also try using `ssh root@192.168.50.1` instead.

If you have previously connected to a *different* machine with the *same* IP address as your B3 via `ssh` from the client PC, you may need to delete its host fingerprint (from `~/.ssh/known_hosts` on the PC) before `ssh` will allow you to connect.

> Incidentally, you should also be able to browse the web etc. from your client (assuming that you connected the B3's `wan` port prior to boot), because the image has a forwarding `shorewall` firewall setup, as of version 1.7.0.

## Using Gentoo

The supplied image contains a fully-configured Gentoo system (*not* simply a [minimal install](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Media#Minimal_installation_CD) or [stage 3](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Media#What_are_stages_then.3F)), with a complete Portage tree already downloaded, so you can immediately perform `emerge` operations (Gentoo's equivalent of `apt-get`) etc. Be aware that, as shipped, it uses UK locale settings and timezone; however, these are easily changed if desired. See the [Gentoo Handbook](https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Base#Timezone) for details.

The full set of packages in the image may be viewed [here](https://github.com/sakaki-/gentoo-on-b3/blob/master/reference/installed-packages) (note that the version numbers shown in this list are Gentoo ebuilds, but they generally map 1-to-1 onto upstream package versions).

It is based on the 5 June 2014 stage 3 release and minimal install system from Gentoo (armv5tel), with all packages brought up to date against the Gentoo tree as of 19 June 2017.

The initial networking setup of the live-USB is as follows (patterned on the setup laid out in my Gentoo wiki page [here](https://wiki.gentoo.org/wiki/Ethernet_plus_WiFi_Bridge_Router_and_Firewall)):

![Initial B3 Networking Setup](https://raw.githubusercontent.com/sakaki-/resources/master/excito/b3/b3_initial_networking_setup.png)

Feel free to change this as desired; see [this volume](https://wiki.gentoo.org/wiki/Handbook:AMD64#Gentoo_network_configuration) of the Gentoo Handbook for further details.
> If you have used previous versions of this live-USB, please note that the initial networking setup has changed. There is no need to specify the `/install/net` or `/install/resolv.conf` files, and the `copynetsetup` service is now disabled.

> Please be aware that, because the image uses `kexec` to boot the [gentoo-b3-kernel](https://github.com/sakaki-/gentoo-b3-kernel), the MACs of the ethernet adaptors (`eth0` and `eth1`) are *not* set by U-Boot, but by the `setethermac` service (see the file `/etc/init.d/setethermac`, viewable [here](https://github.com/sakaki-/gentoo-on-b3/blob/master/reference/setethermac)). Accordingly, if you add a `udev` rule to change the names of these interfaces, their MACs will not be correctly initialized, and you may be unable to connect; so please don't do that ^-^

Note that the initial setup assumes you have a DHCP server on your network (on your ADSL router etc.). However, even if you do not (or have not hooked up your **wan** Ethernet port on boot), you *should* still be able to log in to your B3 (via the `lan` port, or, if available, over WiFi). You can then specify appropriate networking settings in `/etc/conf.d/net` for the `wan` port (`eth0`). Having done so, ensure the `wan` port is connected, and issue (as root) `/etc/init.d/net.eth0 restart` to bring the interface up.

When you are done using your Gentoo system, you can simply issue:
```
b3 ~ # reboot
```
and your machine will cleanly restart back into your existing (Excito) system off the hard drive. At this point, you can remove the USB key if you like. You can then, at any later time, simply repeat the 'power up with USB key inserted and button pressed' process to come back into Gentoo - any changes you made will still be present on the USB key. This makes for an easy way to migrate across gradually to Gentoo if you like, without having to disrupt your normal Excito Debian setup (which you can always just reboot back into at any time).

To power off cleanly (rather than rebooting), you have two options. First, as the image includes Tor's [bubba-buttond](https://github.com/Excito/bubba-buttond) (courtesy of Gordon's [ebuild](https://github.com/sakaki-/gentoo-b3-overlay/tree/master/sys-power/bubba-buttond), migrated into the [gentoo-b3 overlay](https://github.com/sakaki-/gentoo-b3-overlay) as of version 2.0.0), you can simply press the B3's rear button for around 5 seconds, then release it (just as you would on a regular Excito system). The front LED will turn from green to purple after around 20 seconds, then turn off once it is safe to physically remove the power cable.

Second, if you'd rather use the command line, you can issue: 
```
b3 ~ # poweroff-b3
```
which will have the same effect (and follow the same power-down LED sequence).

Have fun! ^-^

## Miscellaneous Points

* The specific B3 devices (LEDs, buzzer, rear button etc.) are described by the file `arch/arm/boot/dts/kirkwood-b3.dts` in the main kernel source directory (and included in the [git archive too](https://github.com/sakaki-/gentoo-on-b3/blob/master/reference/kirkwood-b3.dts), for reference). You can see an example of using the defined devices in `/etc/init.d/bootled`, which turns on the green LED as Gentoo starts up, and back to purple again on shutdown (this replaces the previous [approach](http://wiki.mybubba.org/wiki/index.php?title=Let_your_B3_beep_and_change_the_LED_color), which required an Excito-patched kernel). Note that the USB image uses a slightly patched version of the DTS (available [here](https://github.com/sakaki-/gentoo-on-b3/blob/master/reference/kirkwood-b3-earlyled.dts)), to ensure that the front LED is purple during early boot; (if for some reason you don't want to use this, simply rename or delete the file `kirkwood-b3-earlyled.dtb` in the first partition of the live USB, and the standard `kirkwood-b3.dtb` will be used instead; note that in this case the B3's LED will be off for around 30-40 seconds during boot, which some users find disconcerting).
* The live USB works because the B3's firmware boot loader will automatically try to run a file called `/install/install.itb` from the first partition of the USB drive when the system is powered up with the rear button depressed. In the provided image, we have placed a bootable (interstitial) kernel uImage in that location. Despite the name, no 'installation' takes place, of course!
* As mentioned, *two* kernels are actually used during the boot process. The first, "interstitial" (aka "bootloader") kernel has an integral `busybox`-based initramfs (an archive of which is available [here](https://github.com/sakaki-/gentoo-on-b3/releases/tag/2.0.0#downloads)), within which is a simple init script (which you can see [here](https://github.com/sakaki-/gentoo-on-b3/blob/master/reference/interstitial-init-on-live-usb)); this script attempts to mount the first partition of the USB key (by UUID, so it will work even on a diskless chassis) and then sources the file `/boot/kexec.sh` within it (which you can see [here](https://github.com/sakaki-/gentoo-on-b3/blob/master/reference/kexec-on-live-usb.sh)). This script in turn loads the 'real' kernel zImage from `/boot` (provided, by default, from [gentoo-b3-kernel](https://github.com/sakaki-/gentoo-b3-kernel) via the [gentoo-b3-kernel-bin](https://github.com/sakaki-/gentoo-b3-overlay/tree/master/sys-kernel/gentoo-b3-kernel-bin) package on the image), applies a small [workaround patch](https://lists.debian.org/debian-boot/2012/08/msg00804.html), sets up the kernel command line, loads the device tree blob and (optional) initramfs, and then switches to this 'real' kernel (using `kexec`). You can easily modify the script fragment `/boot/kexec.sh` if you like, for example to change the kernel command line settings.
* The image is subscribed to the following overlays:
  * [`sakaki-tools`](https://github.com/sakaki-/sakaki-tools): this provides the tools `showem` ([source](https://github.com/sakaki-/showem), [manpage](https://github.com/sakaki-/gentoo-on-b3/raw/master/reference/showem.pdf)) and `genup` ([source](https://github.com/sakaki-/genup), [manpage](https://github.com/sakaki-/gentoo-on-b3/raw/master/reference/genup.pdf)). (Note - these replace the old `showem-lite` and `genup-lite` tools.) It also provides the `porthash` tool ([source](https://github.com/sakaki-/porthash), [manpage](https://github.com/sakaki-/gentoo-on-b3/raw/master/reference/porthash.pdf)).
  * [`gentoo-b3`](https://github.com/sakaki-/gentoo-b3-overlay): this provides the `b3-init-scripts` package ([source](https://github.com/sakaki-/gentoo-b3-overlay/tree/master/sys-apps/b3-init-scripts/files)), a modern version of the `lzo` package ([upstream](http://www.oberhumer.com/opensource/lzo/download/); required because of an [alignment bug](https://bugs.debian.org/cgi-bin/bugreport.cgi?bug=757037#32)), and the `buildkernel-b3` tool ([source](https://github.com/sakaki-/buildkernel-b3), [manpage](https://github.com/sakaki-/gentoo-on-b3/raw/master/reference/buildkernel-b3.pdf)). It also provides the `b3-check-porthash` package ([source](https://github.com/sakaki-/gentoo-b3-overlay/tree/master/app-portage/b3-check-porthash/files)) and the `gentoo-b3-kernel-bin` package ([ebuild](https://github.com/sakaki-/gentoo-b3-overlay/tree/master/sys-kernel/gentoo-b3-kernel-bin)), used to install the autobuilt [gentoo-b3-kernel](https://github.com/sakaki-/gentoo-b3-kernel) binaries.
  * As of version 2.0.0, Gordon's [`bubba`](https://github.com/gordonb3/bubba-overlay) overlay, which provides ebuilds to provide the original Excito web-based interface on the B3 under Gentoo, is not pre-installed on the image (his [bubba-buttond](https://github.com/sakaki-/gentoo-b3-overlay/tree/master/sys-power/bubba-buttond) ebuild having been migrated into the [gentoo-b3](https://github.com/sakaki-/gentoo-b3-overlay) overlay). If you *do* wish to use this repo, simply move the file `/etc/portage/bubba.conf` into `/etc/portage/repos.conf`, and then issue `emaint sync --repo bubba` (or similar update command). Interested users are also encouraged to check out Gordon's excellent [bubbagen](https://github.com/gordonb3/bubbagen) bootable images for the B3.
* <a name="binhost_unsubscribe">A cron-scripted weekly autobuild (`genup`) binhost has been set up at https://isshoni.org/b3, and the image is configured to use this by default (see `/etc/portage/make.conf`: `FEATURES="${FEATURES} getbinpkg"` and `PORTAGE_BINHOST="https://isshoni.org/b3"`; simply comment out these lines if you do not wish to use this facility). Furthermore, to ensure that the Portage ebuild tree is kept in sync with the binhost, an `rsync` mirror has been provided at `rsync://isshoni.org/gentoo-portage-b3`. This mirror is slaved off the binhost's tree (itself based upon a `webrsync-gpg` authenticated snapshot) and updated at the same time the new binary packages are uploaded each week. The image is configured to use this mirror for its main Portage tree (see `/etc/portage/repos.conf/gentoo.conf`); however, as `rsync` is an unauthenticated protocol, the image *also* uses the [porthash](https://github.com/sakaki-/porthash) utility to ensure the tree has not been tampered with in transit. (The hook `/etc/portage/repo.postsync.d/b3-check-porthash` (set up by the [b3-check-porthash](https://github.com/sakaki-/gentoo-b3-overlay/tree/master/app-portage/b3-check-porthash) package) is what triggers the signed hash check on updates.)

   If you would rather use a standard Gentoo `rysnc` source instead, simply edit `/etc/portage/repos.conf/gentoo.conf` and set e.g. `sync-uri = rsync://rsync.us.gentoo.org/gentoo-portage`. Be aware that if you *do* do this, *and* use the `isshoni.org` binhost for updates, you may still end up building quite a lot from source on your own machine, should e.g. a new version of a large package like `gcc` be posted to the "gentoo" tree in-between the weekly binhost updates (using the custom `rsync` source prevents this kind of thing from happening).

* Also, since, by default, Gentoo will *not* use a binary package for update unless the USE flags selected when building it match those on your machine, a custom profile, `gentoo-b3:default/linux/arm/13.0/armv5te/b3`, has been provided, which helps keep these (and some other critical build settings) in sync. You can view this profile (provided via the [gentoo-b3](https://github.com/sakaki-/gentoo-b3-overlay) overlay) [here](https://github.com/sakaki-/gentoo-b3-overlay/tree/master/profiles/targets/b3). In addition to USE flags, the custom profile also provides package masks, certain `make.conf` settings, package keywording etc. The profile is sync'd by the binhost as part of the weekly build cycle, and will be picked up on the B3 during a `genup` run, so any USE flag modifications, new masks etc. required to build an updated version of a package can be distributed to your machine without manual intervention; again, simplifying the update process. Note that any settings you make in `/etc/portage/...` override those in the profile, so you always have control.

  Nevertheless, if you *don't* want to use this facility, simply issue `eselect profile set default/linux/arm/13.0/armv5te` to revert back to the vanilla profile. You'll need to merge back some changes into your `/etc/portage/make.conf`, `/etc/portage/package.use` etc. if you do so however, in order to continue to build packages on your B3 under Gentoo. Refer to the various files [in the custom profile](https://github.com/sakaki-/gentoo-b3-overlay/tree/master/profiles/targets/b3) to see which edits must be made.

* As of version 1.7.0, the `shorewall` firewall (front-end) is included and enabled. If you wish to run e.g. a web server on your B3, please remember to add the appropriate firewall rules (see my Gentoo wiki page [here](https://wiki.gentoo.org/wiki/Ethernet_plus_WiFi_Bridge_Router_and_Firewall) for some further information).
 * Please note that the firewall, as initially configured, will allow `ssh` traffic on the `wan` port also. Note also that `sshd` (see `/etc/ssh/ssdh_config`) is initially configured to *allow* password-based login for `root` (you may wish to change this, once you have created at least one regular user with the ability to `su` to `root`).
* To allow additional inbound traffic to your B3, the file you need to edit is `/etc/shorewall/rules`. Add new entries to the bottom of this file. For example, to allow inbound port 8000/TCP from `br0` (the `loc` zone) and 8001/UDP, 8001/TCP from `eth0` (the `net` zone), you would add:
```
ACCEPT loc $FW tcp 8000
ACCEPT net $FW udp 8001
ACCEPT net $FW tcp 8001
```
Then simply reboot your B3, or issue `/etc/init.d/shorewall restart` to pick up the changes.
* If you have a WiFi-enabled B3, the corresponding network interface is named `wlan0` (there is a `udev` rule that does this, namely `/etc/udev/rules.d/70-net-name-use-custom.rules`). Please note that this rule will **not** work correctly if you have more than one WiFi adaptor on your B3 (an unusual case).
* The WiFi settings are controlled by `hostapd`, and my be modified by editing `/etc/hostapd.d/b3.conf`. I recommend that you at least change the passphrase (if you have a WiFi-enabled B3)!
* The image now includes a 1GiB swap partition, and (since a minimum 8GB key is now required, rather than 4GB) also has sufficient space in its root partition to e.g., perform a kernel compilation, should you so desire.
* If you have a USB key larger than the minimum 8GB, after writing the image you can easily extend the size of the second partition (using `fdisk` and `resize2fs`), so you have more space to work in. See [these instructions](http://geekpeek.net/resize-filesystem-fdisk-resize2fs/), for example.

## <a name="hdd_install">Installing Gentoo on your B3's Internal Drive (Optional)

If you like Gentoo, and want to set it up permanently on the B3's internal hard drive, you can do so easily (it takes less than 5 minutes). The full process is described below. (Note, this is strictly optional, you can simply run Gentoo from the USB key, if you are just experimenting, or using it as a rescue system.)

> **Warning** - the below process will wipe all existing software and data from your internal drive, so be sure to back that up first, before proceeding. It will set up:
* /dev/sda1 as a 64MiB boot partition, and format it `ext3`;
* /dev/sda2 as a 1GiB swap partition;
* /dev/sda3 as a root partition using the rest of the drive, and format it `ext4`.

> Note also that the script [`/root/install_on_sda.sh`](https://github.com/sakaki-/gentoo-b3-overlay/blob/master/sys-apps/b3-init-scripts/files/install_on_sda.sh-3) will install using a DOS partition table (max 2TiB); if you'd rather use GPT, then use [`/root/install_on_sda_gpt.sh`](https://github.com/sakaki-/gentoo-b3-overlay/blob/master/sys-apps/b3-init-scripts/files/install_on_sda_gpt.sh-3) instead. [All B3s](http://forum.mybubba.org/viewtopic.php?f=7&t=5755) can boot from a GPT-partitioned drive; however, please note that if your HDD has a capacity > 2TiB, then only those B3s with a [relatively modern](http://forum.mybubba.org/viewtopic.php?f=9&t=5745) U-Boot will work correctly. The DOS partition table version should work for any size drive (but will be constrained to a maximum of 2TiB).

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
And let the system shut down and come back up. **Don't** press the B3's back-panel button this time. The system should boot directly off the hard drive. You can now remove the USB key, if you like, as it's no longer needed. Wait 60 seconds or so, then from your PC on the same subnet issue:
```
> ssh root@b3
Password: <type gentoob3 and press Enter>
b3 ~ # 
```
Of course, if you changed root's password in the USB image, use that new password rather than `gentoob3` in the above.

Once logged in, feel free to configure your system as you like! Of course, if you're intending to use the B3 as an externally visible server, you should take the usual precautions, such as changing `root`'s password, configuring the firewall, possibly [changing the `ssh` host keys](https://missingm.co/2013/07/identical-droplets-in-the-digitalocean-regenerate-your-ubuntu-ssh-host-keys-now/#how-to-generate-new-host-keys-on-an-existing-server), etc.

## Compiling Your Own Kernel (Optional)

As shipped, the image uses the [gentoo-b3-kernel-bin](https://github.com/sakaki-/gentoo-b3-overlay/tree/master/sys-kernel/gentoo-b3-kernel-bin) package to follow the [gentoo-b3-kernel](https://github.com/sakaki-/gentoo-b3-kernel) binary, which is autobuilt and released on a weekly basis, tracking the most modern `~arm` [gentoo-sources](https://wiki.gentoo.org/wiki/Kernel/Overview#General_purpose:_gentoo-sources) kernel available in the Gentoo tree. As such, your "real" kernel will automatically be updated (along with the userland packages in your system) whenever you run `genup` (see [below](#genup)).

However, if you'd like to compile your *own* kernel for your new system (for example, to set specific config options), you can do so easily (even if still running from the USB - it has sufficient free space). Note that you **must** use at least version 3.15 of the kernel, as this is when the B3's device-tree information (the `arch/arm/boot/dts/kirkwood-b3.dts` file discussed earlier) was integrated into the mainline.

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
Now remove the provided binary kernel (if you have not already done so):
```
b3 linux # emerge --unmerge gentoo-b3-kernel-bin
```
Next, whether running Gentoo from your B3's internal hard drive or live-USB, issue:
```
b3 linux # buildkernel-b3 --menuconfig --zimage
```
The `buildkernel-b3` script (supplied) will build the kernel, modules and device tree blob, and copy them to the appropriate directories for you (see its manpage [here](https://github.com/sakaki-/gentoo-on-b3/raw/master/reference/buildkernel-b3.pdf)). It will, by default, use your running kernel's config as a basis, and (if you specify `--menuconfig` when invoking it, as above), offer you the chance to modify the kernel configuration using the standard editor. Once completed, when you restart, you'll be using your new kernel!

> **NB: if the kernel build *fails* for some reason, be sure to re-install your original binary kernel, before proceeding.** To do so, issue `emerge gentoo-b3-kernel-bin`. Do not attempt to reboot until this command has completed.

> Note - if you are familiar with the standard Linux kernel build workflow, you can use that instead - there's no need to use `buildkernel-b3`. Just make sure to: 1) uninstall `gentoo-b3-kernel-bin` before you begin; 2) place the resulting `zImage` and `kirkwood-b3.dtb` files in the `/boot` directory (at the top level, *not* in `/boot/boot` or `/boot/install` where the insterstitial kernel lives), and 3) install the modules into `/lib/modules`, before rebooting. The `zImage` does *not* need to be patched in any way - the interstitial ("bootloader") kernel will take care of all that for you. Similarly, there's no need to append the DTB to the kernel, or hardcode the command line (you can change these things via the file `/boot/kexec.sh`, after the kernel is built).

Of course, you can easily adapt the above process, if you wish to use Gentoo's hardened sources etc.

> Please note that there was a major re-organization of the Marvell architecture in version 3.17 of the kernel, with [mach-kirkwood being removed](https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=ba364fc752daeded072a5ef31e43b84cb1f9e5fd). As a result, the required format of the config file changed signficantly (for the B3), such that a simple `make olddefconfig` on a < 3.17 kernel config will no longer generate a bootable kernel. As such, if building a >= 3.17 kernel, you should use the [v2.0.0 configs](https://github.com/sakaki-/gentoo-on-b3/tree/2.0.0/configs) from this project as a basis (as these have the new schema); however, if building 3.15 <= x < 3.17, use the [v1.1.0 configs](https://github.com/sakaki-/gentoo-on-b3/tree/1.1.0/configs) instead. Versions < 3.15 do not have device-tree support for the B3, and should not be used.

It is also possible to cross-compile a kernel on your (Gentoo) PC, which is *much* faster than doing it directly on the B3. Please see the instructions at the tail of this document.

> Alternatively, if you set up `distcc` (also covered in the instructions below), an invocation of `buildkernel-b3` on your B3 will *automatically* offload kernel compilation workload to your PC. However, if you do use `distcc` in this way, be aware that not all kernel files can be successfully built in this manner; a small number (particularly, at the start of the kernel build) may fall back to using local compilation. This is normal, and the vast majority of files *will* distribute OK.

## <a name="genup">Keeping Your Gentoo System Up-To-Date

You can update your system at any time (whether you are running Gentoo from USB or the B3's internal drive). As there are quite a few steps involved to do this correctly on Gentoo, I have provided a convenience script, `genup` to do this as part of the image. So, to update your system, simply issue:
```
b3 ~ # genup
   (this will take some time to complete)
```
This is loosely equivalent to `apt-get update && apt-get upgrade` on Debian. See the [manpage](https://github.com/sakaki-/gentoo-on-b3/raw/master/reference/genup.pdf) for full details of the process followed, and the options available for the command.

As of version 2.0.0, the live-USB will attempt to use binary packages from the binhost https://isshoni.org/b3 where these files are available (and USE-flag compatible), only falling back to local (source-based) compilation where necessary. Because the image (by default) keeps its main Portage tree and installed-package USE flags in lockstep with the binhost (see [earlier](#binhost_unsubscribe)), local compilation should *only* be necessary for packages you explicitly add to the default set (or whose USE flags you explicitly change, for example, by setting `-bindist`).

> The https://isshoni.org/b3 binhost is updated automatically on a weekly basis by a B3 running a `cron`-scripted [`genup`](https://github.com/sakaki-/genup) job, as is the autobuilt [gentoo-b3-kernel](https://github.com/sakaki-/gentoo-b3-kernel). Although I make no guarantees about the future availability of either service, I currently use this infrastructure for my own production B3s, so it should be around for a while. Use the supplied binary packages (and kernels) at your own risk.

> Note that, if you have installed many packages in addition to those shipped with the live-USB, or have [chosen *not* to use the binhost](#binhost_unsubscribe) then, because Gentoo is a source-based distribution, and the B3 is not a particularly fast machine, updating may take a number of hours, if many packages have changed. However, `genup` will automatically take advantage of distributed cross-compiling, using `distcc`, if you have that set up (see the next section for details).

> Even with the binhost backing, be aware that a full `genup` run will take around an hour to complete on your B3 (due to time taken by `rsync`, `Portage`'s dependency tree processing etc.).

When the update has completed, if promped to do so by `genup`, then issue:
```
b3 ~ # dispatch-conf
```
to deal with any config file clashes that may have been introduced by the upgrade process.

If your kernel has been upgraded during the genup process, reboot your B3 to start using it.

For more information about Gentoo's package management, see [my notes here](https://wiki.gentoo.org/wiki/Sakaki's_EFI_Install_Guide/Installing_the_Gentoo_Stage_3_Files#Gentoo.2C_Portage.2C_Ebuilds_and_emerge_.28Background_Reading.29).

> You may also find it useful to keep an eye on the 'Development' forum at [excito.com](http://forum.excito.com/index.php), as I occasionally post information about this live-USB there.

### Automating genup

Because of the binhost backing (assuming you choose to retain it), running `genup` is not a particularly onerous process, and I would encourage you to run it weekly, to ensure your B3's kernel and userland software remains up-to-date. To do so, simply place the below script in the `/etc/cron.weekly` directory (name it e.g. `weekly_genup`), and make it executable:

```bash
#!/bin/bash
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/opt/bin"
genup >/var/log/latest-genup-run.log 2>&1
RC=$?
# if you have mail sending configured on your B3, replace your@email.address and
# uncomment the lines below
#if ((RC==0)); then
#	mail -s "B3 genup run SUCCEEDED" your@email.address < /var/log/latest-genup-run.log
#else
#	mail -s "B3 genup run FAILED" your@email.address < /var/log/latest-genup-run.log
#fi
```

## Have your Gentoo PC Do the Heavy Lifting!

The B3 does not have a particularly fast processor when compared to a modern PC. While this is fine when running the device in day-to-day mode (as a mailserver, for example), it does pose a bit of an issue with a primarily-source-based distribution like Gentoo, where you must compile any packages not provided by your binhost to install or upgrade them. Everything works, but an install of a new package can often take hours, which soon gets tiresome.

However, there is a solution to this, and it is not as scary as it sounds - leverage the power of your PC (assuming it too is running Gentoo Linux) as a cross-compilation host!

For example, you can cross-compile kernels for your B3 on your PC very quickly (around 5-15 minutes from scratch), by using Gentoo's [`crossdev`](http://gentoo-en.vfose.ru/wiki/Crossdev) tool. See my full instructions [here](https://github.com/sakaki-/gentoo-on-b3/wiki/Set-Up-Your-Gentoo-PC-for-Cross-Compilation-with-crossdev) and [here](https://github.com/sakaki-/gentoo-on-b3/wiki/Build-a-B3-Kernel-on-your-crossdev-PC) on this project's [wiki](https://github.com/sakaki-/gentoo-on-b3/wiki).

Should you setup crossdev on your PC in this manner, you can then take things a step further, by leveraging your PC as a `distcc` server (instructions [here](https://github.com/sakaki-/gentoo-on-b3/wiki/Set-Up-Your-crossdev-PC-for-Distributed-Compilation-with-distcc) on the wiki). Then, with just some simple configuration changes on your B3 (see [these notes](https://github.com/sakaki-/gentoo-on-b3/wiki/Set-Up-Your-B3-as-a-distcc-Client)), you can distribute C/C++ compilation (and header preprocessing) to your remote machine, which makes system updates a *lot* quicker (and the provided tools [`genup`](https://github.com/sakaki-/genup) and [`buildkernel-b3`](https://github.com/sakaki-/buildkernel-b3) will automatically take advantage of this distributed compilation ability, if available).

## Feedback Welcome!

If you have any problems, questions or comments regarding this project, feel free to drop me a line! (sakaki@deciban.com)
