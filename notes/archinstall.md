# Use archinstall to install ArchLinux

Using `archinstall` is definitely the easiest and best way to install ArchLinux. While ArchLinux purists will likely suggest [installing ArchLinux like it says on the ArchWiki](https://wiki.archlinux.org/title/Installation_guide), the `archinstall` command is defintely way better.

## Getting Started

Before you install, you need to burn an ArchLinux image to a USB Drive.  I recommend finding a cheap, low capacity USB Drive say 8GB or less because the only reason you'll ever need to use this drive is to load the ArchLinux data *on to the memory* and then remove the drive once that is done.

To prove how old I am, and how important that last part is, my elementary school used to have a whole bunch of Apple II computers where they would load a program from the floppy disk drive, then once the program loaded onto the computer (because it was now stored in the computer's RAM), the floppy disk would then be removed and put into the next computer to load the program on to that.

There's another reason to do this, but I'll explain later.

You'll need to download an Arch Linux image from the [download](https://archlinux.org/download/) then scroll down to the part of the page with all the mirrors.

Pick a mirror website. Look for a file called `archlinux-x86_64.iso` or `archlinux-YYYY.MM.DD-x86_64.iso` where `YYYY.MM.DD` is a date, usally the first of the month like `2023.01.01`. They technically are the same file, but the one with the date is more helpful because then you'll know what version of the `.iso` file is on the drive if you ever want to wipe the USB drive you plan to use for something else in the future.

If you are using Windows, I would suggest installing [Balena Etcher](https://www.balena.io/etcher). Once Etcher is installed, open it. Select that `.iso` file we downloaded, select the USB drive you want to burn it to (which hopefully is plugged in) and click "Flash!".  In a few minutes, the drive will be ready to burn to another computer with an blank harddrive.

> TODO: I should probably include directions for using a virtual machine later.

If you are using Linux, you can do the same thing, assuming the Balena Etcher package isn't "Out of date".  On the other hand, if you didn't install `yay` (which I will explain how to do later so you can install packages from the ArchLinux User Repository (AUR)), I recommand using the dangerous `dd` command.

> **WARNING!** `dd` is DANGEROUS! You need to know what block device the USB drive is identified before you run this command. You're harddrive is likely `/dev/sda`. DON'T USE THAT! You will ruin your computer.  The `of` argument in the `dd` command below has a value of `/dev/sdx`, where the `x` represents the letter of the drive you want to burn the image to. We recommend that before you run this command below, do a `lsblk`, plug in the USB drive, then do an `lsblk` again. The outputs of the `lsblk` commands should be different in that the second time around a new device might show up. Let's assume that the device is `/dev/sdb` which may have a `/dev/sdb1` partition. You only need to have the USB device plugged in. DO NOT MOUNT IT! If you have, that's OK. Unmount it, but keep it plugged in so that it still shows up when `lsblk` is run.  Once you are certain that that is the device you want to burn the `.iso` file to, then and only then should you run this command below.

```bash
sudo dd bs=4M if=path/to/archlinux-version-x86_64.iso of=/dev/sdx conv=fsync oflag=direct status=progress
```

> TODO: Is there a way to use `curl` to pipe our `.iso` file into the `if` argument such that we can download and flash? Probably. I'll look into lit later.

Once the image is burned to the device, you can remove it from your computer and plug it into the other computer that you want to put ArchLinux on.

## Installation

Before you start up the other computer, make sure that it is powered off and that it has a blank hard drive. I will NOT explain how to dual boot. It is a P.I.T.A. to do on one harddrive, and generally most of the instructions are written to have Windows as the dominant system.  It's much better to simply put one operating on one harddrive and another operating system on a different harddrive and not have to worry about things like *repartitioning* or hardware failure.  K.I.S.S. (Keep it simple, stupid!)

With the USB drive plugged in and your computer currently off, press the power button, but be vigilant! We need you to go into your computer's boot menu or the BIOS menu to have it start up with the USB disk. YMMV on this. You may want to Google the type of computer that you have to figure out how that it was done.  For me, it was "Press F7". For other people, it might be "Press F6", "Press F12", "Press the Backspace button". Whatever.

After you have successfuly booted from the USB drive, you might be given a menu of options on how to run the computer. One of those options should be to run ArchLinux and you should select that.

The next part will likely take about a minute or so, depending on how much RAM you have, which in 2023, you should probably have about 8GB or more of RAM, although, you can probably do this with just 1GB.  You'll likely see a black screen. This is normal. More than likely the USB drive is copying the contents to the RAM.

This step is done once you see the installation prompt which should have a line of colorful characters and a line that says `root@archiso ~ #`. That is your **prompt**.  When you reach this **unplug the USB drive**.

> Method to the madness: I didn't realize it, but after several tries of trying to run the `archinstall` script, it is important that the only drive that should be recognized is the `/dev/sda` drive, which is the harddrive of the computer we are putting stuff on.  While all this install stuff in currently running from the RAM, if you run `lsblk` or `fdisk -l` and your USB drive is still plugged in, the USB drive will be recognized as `/dev/sdb`, which initially will show that it has two partitions if you have `lsblk`, but once the USB drive has done what it needs to do, that `/dev/sdb1` partition might disappear and the `archinstall` script will assume that `/dev/sdb` was part of the system we were installing stuff on, but the `/dev/sdb1` partition, which is empty, will be purged from the list of block devices, which `lsblk` won't find.  If you run `archinstall` after you've done your configuration, you'll likely run onto a error saying that `/dev/sdb1` could not be found.  And that's going to be a problem.  So once you've reached the prompt, you can and should remove the USB drive.

## Get online

We're going to need an internet connection to download packages.  If you have a wired connection, you can simply plug-in an Ethernet cable and ping Google to see if you are up an running. However, there's a good chance you are putting this on a device that probably doesn't have an Ethernet port put plug in, but you probably have WiFi.

Enter [`iwctl`](https://wiki.archlinux.org/title/iwd). This command will be used to do four things:

1. Find your WiFi device (more than likely `wlan0`)
2. Scan for local WiFi networks.
3. List those networks.
4. Connect to a network.

Enter the `iwctl` command. You will likely see a new prompt `[iwd]#` indicating you are in the `iwd` program that `iwctl` uses.

> Note: This program will likely refresh the screen. This is normal. Try not to be put off by it.

```bash
# Step 1. Find your device. Let's assume that you are looking for `wlan0`
device list

# Step 2. Use that device to scan for networks. This won't output anything, but the next command will.
station wlan0 scan

# Step 3. List those networks. The network name (also called an SSID) will be listed along with the strenght of the signal and if it requires a pass key (PSK). It should!
station wlan0 get-networks

# Step 4. Type in the SSID you are trying to connect to. If the name has spaces in it, we recommand you enclose the SSID in quotes.
# If you are asked to enter a passphrase after you enter this command, do it.
station wlan0 connect "Comcast Sucks"

# Step 5. Exit the program
exit
```

Once you have done all this, you can check to see if you are connected to the internet.  Typically, a lot of nerds will say `ping google.com`, but there's another command called `curl` which can be used to download stuff from the internet or display information in the command like, I recommend doing this.  One of my favorite sites to do this is [`wttr.in`](https://wttr.in/) because it will look up your local weather (using some geographic IP information), displays the current weather and a three day forecast.  You could also use [`ipinfo.io`](https://ipinfo.io/) which will also display geographic IP information as well as take a guess as to where you are located. More than likely, it will show where your ISP's offices are located and their zip code.  It's a lot of I.T. nerd stuff. I'll probably elaborate later.

```bash
curl ipinfo.io
curl wttr.in
```

Regardless of which website you use, you either should see all that I.T. info or a weather report. If you don't, you should check to make sure you entered everything correctly or use a different network that you have access too.  I highly recommend never using a network that you don't enter a password to get a connection as public WiFi is dangerous and a security risk.  If you have to use public WiFi, use a VPN.  (Sorry, I don't have instructions for that here.)

## Arch Install

Finally, we're at the part for why we are here in the first place.  You're going to see a list of menu tems.

```text
Set/Modify the below options

Archinstall language        set: English (100%)
Keyboard layout             set: us
Mirror region               set: []
Locale language             set: en_US
Locale encoding             set: UTF-8
Drive(s)
Bootloader                  set: systemd-bootctl
Swap                        set: True
Hostname                    set: archlinux
Root password               set: None
User account
Profile                     set: None
Audio                       set: None
Kernels                     set: ['linux']
Additional packages         set: []
Network configuration       set: Not configured, unavailable unless setup manually
Timezone                    set: UTC
Automatic time sync (NTP)   set: True
Optional repositories       set: []

Save configuration
Install
Abort
(press "/" to search)
```

### The first five options

If you live in the United States or speak English, you're probably not going to worry too much about changing those first few settings, although I would recommend in `Mirror region` you change the value from `[]` (blank) to `United States` or `Worldwide`. Fortunately, you don't have to scroll all the way to the bottom of the list to select those options. If you press the Up key at the top of the list, it will take you to the bottom of the list.

Not all of the menu items in the `archinstall` command are visible. Likely, whoever wrote this script used [python inquirer](https://python-inquirer.readthedocs.io/en/latest/), which as a Node.js developer, the node version of `inquirer` is just as crappy when it comes to displaying menus and just as buggy. There is a good chance you will run into a bug while running this program, generally at the `Drive(s)` menu where 99% of the time, everything that breaks is the fault of that option.

I recommend setting all the other settings before setting the `Additional packages` option especially if you have a long list of packages you want to install (and believe me, there will be some things here that I suggest that you should just because they will make using Linux way more fun).

So, if you are an American, the first five items on that list should look like this.

```text
Archinstall language        set: English (100%)
Keyboard layout             set: us
Mirror region               set: ['United States']
Locale language             set: en_US
Locale encoding             set: UTF-8
```

> Note: If you know more than one language, choose the one that you know best or that you consider your native tongue.  You can add other keyboard layouts and locals later to suit your needs

I'm not going to touch the `Drive(s)` option yet.

### Bootloader and Swap

The `Bootloader` and `Swap` partitions should be left as they are.  If you've bough a computer within the last decade, you should be using the `systemd-bootctl` instead of GRUB bootloader even if you are trying to dual boot.  And a good Linux system should have a swap partiotion for virtual memory (space that is allocated onto a harddrive that is treated as RAM). So leave these two settings alone.

```text
Bootloader                  set: systemd-bootctl
Swap                        set: True
```

### Hostname, Root Password, and User Managment

You should change your host name. The default is `archlinux`, and if you've ever used Windows, you've probably seen how crappy the set that up by using the model of your computer. So let's give your computer a better name. I've been watching a lot of *The Owl House* lately, let's use `lumity` as the hostname for our computer.

```text
Hostname                    set: lumity
```

In Linux, there is one default user, the `root` user. The `root` user's home directory is `/root`.  The `root` user is the system adminstrator.  To make sure that baddies stay out, or to make sure we don't execute any bad system-wide level commands, it is **absolutely necessary that the root user have a password set**. So set the root password.  You will be asked to do this twice, which is useful if you mistype it in either two instances, the password will not be set until both attempts are the same.  For personal computers, it doesn't need to be that long, even if the prompt tells you your password is "weak".  In a more business oriented setting, longer passwords are highly recommended.  This recommendation also applies to users as well, which we will set up in the next step.

```text
Root password               set: **********
```

The best part about Linux (even more so with the `archinstall` script) is setting up users.  For instance, suppose I wanted to add two users: Luz (username: `luz`) and Amity (username: `amity`).  Let's say that Luz owns the computer.  When we add a user, a user may be permitted to run system adminstrator commands as `root` by prefixing a command with `sudo`.

Since Luz owns the computer, she can set her user account to have adminstrator access, allowing her to use `sudo` to take care of system upgrades and other adminstrative stuff.  Amity won't have that same access, unless she asks Luz. (She probably would, but let's assume that she doesn't in our scenario.)

First, we select `User account`.  The typical linux system should have at least one other user besides the `root` user.  If you've ever wondered why Windows has that extra set of folders for a "System Adminstrator" its because that same user setup was borrowed from Unix.

Next, select `Add a user`. You will be asked to enter a user name. Our first user will be `luz`. You will then be asked to enter your user password. You will enter this twice so be sure to remember it.  Even the main users (`luz`) should have a different password than her `root` user password if she uses ths computer as a web server.  As I previously stated, pick something long and [**NEVER** use something that is easy to guess](https://nakedsecurity.sophos.com/2010/12/15/the-top-50-passwords-you-should-never-use/) or that can be associated with your identity. (For example, Don't use words or names of people you love or names of pets. So for Luz, using her Mom's name `Camila` or her girlfriend's name `Amity` or even that lovable little titan `King` would be terrible passwords to use.  Like wise, for Amity, using her Penstagram handle `WitchChick128`, the name of that adorbable demon kid `Braxas`, her cat palasmin `Ghost` or her girlfriend's name `Luz` are all really bad choices for passwords.)  I went through the trouble of rewriting the [password generator](https://passwordsgenerator.net/), which had been offline for almost a year, from scratch to create [**my own Password Generator**](https://jrcharney.github.io/password-generator/).  So if you are looking for a way to pick a password, defintely give it a try and **WRITE IT DOWN** in a notebook somwhere.  Don't use something like Lastpass where it could be hacked.  Passwords should be difficult to access and just as tough to remember. So put it somewhere where pen meets paper and keep that notebook safe.

```text
Enter username (leave blank to skip): luz
Password for user "luz":
And one more time for verification:

Should "luz" be a superuser (sudo)?

  no (default)
> yes
```

User adminstration should look a lot like this

```text
username | password | sudo
----------------------------
luz      | ******** | True
amity    | ******** | False
```

When you have added all the users to your system, you can select `Confirm and exit`.

```text
User account                set: 2 User(s)
```

### Profile, Audio, and Kernel

The `Profile` set up generally describes how you plan on using your computer to install some basic software packages.  The four typical options are `desktop`, `minimal`, `server`, and `xorg`.  Probably the two most used options on the list are `desktop` and `server`.  The people who pick `server` typically are trying to use their computer as either a webserver, database storage, or some information technology stuff.  For our purpose, we will choose `desktop`.

When we choose `desktop`, we will be asked what desktop environment we would like to use.  For most desktop computer and laptop, [KDE Plasma](https://kde.org) (`kde`) is ideal and is used on the Steam Deck.  A lot of folks like to use [GNOME](https://www.gnome.org/), but I find using it to be boring.  If you have something with some low specifications, [LXDE](https://www.lxde.org/) might be a better option, but that doesn't apepar to be an option, but [Enlightenment](https://www.enlightenment.org/) is.  I like using [i3](https://i3wm.org/) (`i3`) on experimental devices.  Everyone keeps talking about how the Wayland compositor, which [Sway](https://swaywm.org/) uses, should be ready, but from experience, it's 2023, and I'm still using X11 on everything. [Wayland is ready-ish](https://arewewaylandyet.com/), but the elephant in the room continues to be how it behaves with graphics cards, especially the ones made by nVidia.  `sway` is basically a version of `i3` that run with Wayland, but given the choice between `i3` and `sway`, I'd still stick with `i3`.

> Note: If you choose `i3` you may be presented with two options `i3-wm` or `i3-gaps`. At the end of 2022, the `i3-gaps` project merged into `i3`. `i3-gaps` was a fork of `i3` but it allowed for things like borders and window spacing.  These features should be part of `i3` now.

After you choose a desktop environment, you will likely be asked what graphics driver to use.  Linux is all about open source, and there are some folks who sour over proprietary software, but don't let that influence you.

The following options are on the list

- AMD / ATI (open-source)
- All open-source (default)
- Intel (open-source)
- Nvidia (open kernel module for newer GPUs, Turing+)
- Nvidia (open-source noveau driver)
- Nvidia (proprietary)
- Vmware / VirtualBox (open-source)

So which one of these should you choose?
- If you absolutely do not no, selecting "All open-source" would be ideal.
- If you know you have an AMD or ATI brand graphics card, use the "AMD / ATI" drivers.
- If you know you have an Intel graphics card, use the "Intel" drivers
- If you know you have NVidia drivers, use the "Nvidia (proprietary)" drivers. I'm sure Linus Sebastian has probably said something about this before.
- More than likely, if you are using a virtualization of Arch Linux with Vmware or VirtualBox, then use "Vmware / VirtualBox".

For `Audio`, theirs no debate: "pipewire".  Pipewire replaces pulseaudio.

In terms of `Kernels`, leave it set to `linux`.  If security is a big deal, consider `linux-hardened`, especially if you chose a server profile two steps ago.  I'm not sure what `linux-zen` is for. There's also a `linux-lts` option for people who don't want to upgrade as much, however, I would say `linux` is the ideal option. If they had said `linux-nightly`, I woul have picked `linux-lts`, but since the default is `linux`, I would say that `linux` is safe to use.  Most people generally upgrade their system about every couple of week or once a month. Even so, leaving it as `linux` is prefered, especially if there is a critical update that either `linux` or `linux-hardened` has, but `linux-lts` doesn't.

```text
Profile                     set: Profile (desktop)
Audio                       set: pipewire
Kernels                     set: ['linux']
```

I'll get to the `Additional packages` later as there are a lot of things I would suggest adding, for now, let's take care of the last four items on the list.

### The last four options

Before we ran `archlinux`, we had setup our internet configuration.  In `Network Configuration`, we are presented with four options.

- No Network Configuration
- Copy ISO network configuration to installation
- Use Network Manager
- Manual configuration

I would highly recommend neither that first option or that last option.

The default of `Network configuration` is `Not configured` or `No Network Configuration`. Whe you start up Linux next time, you'll likely need to do all that stuff we did in the "Geo Online" section.  Similarly, the last option `Manual configuration` would require you do to the same thing, but with more steps.

If you are using KDE, GNOME, or any desktop environment that looks like KDE or GNOME, defintely choose `Use Network Manager`.  However, if you are using something like `i3`, `awesome`, `sway` or something that is similar to these desktop environments, `Copy ISO network configuration to installation` is your best bet.  Basically, it will copy all the stuff you did to set up this installation onto your harddrive. KDE and GNOME users will get similar results with `Use Network Manager` but they will have a graphical user interface program.

Having been around the block a few times, and since I am also using `i3`, I'm using the `Copy ISO network configuration to installation` option.

`Timezone` seems pretty straightforward.  As with `Mirror region`, if you don't want to scroll through everything, press Up at the top of the list. Near the bottom of the full list are the `US/...` options. For Ms. Noceda's computer in Connecticut, that would be set to `US/Eastern`. Alternatively, scrolling down to `America/New_York` would also be acceptable.  In some Linux distributions, the list is a bit more graphical.  I would recommend visiting a site like [Zeitvershiebung.net](https://www.zeitverschiebung.net/) or [IpInfo.io](https://ipinfo.io/) to find the official IANA timezone name.

Assuming your computer has one of those coin batteries that tracks the time even when the computer is off, I would also recommend keeping `Automatic time sync (NTP)` set to `True`.  Automatic time sync uses the Network Time Protocol (NTP) to reach out to one of the various timekeeping websites (such as [time.gov](https://www.time.gov/)) to maintain what time your computer has.

Lastly, in the `Optional repositories option`, I would suggest enabling the `multilib` repository. If you are using Steam, doing retro gaming, or doing some legacy IT stuff, you should defintely include that repository.  Do not selecting `testing`!  The `testing` repo contains unstable software.  Not selecting it also is the reason why I said earlier that using the `linux` option in `Kernels` is defintely OK because the tesing branch of the Linux kernel is in the `testing` repo.  TLDR: Only pick `multilib`.

```text
Network configuration       set: Copy ISO Configuration
Timezone                    set: America/New_York
Automatic time sync (NTP)   set: True
Optional repositories       set: ['multilib']
```

With all that said, here's what the menu should look like so far for the Lumity computer.

```text
Archinstall language        set: English (100%)
Keyboard layout             set: us
Mirror region               set: ['United States']
Locale language             set: en_US
Locale encoding             set: UTF-8
Drive(s)
Bootloader                  set: systemd-bootctl
Swap                        set: True
Hostname                    set: lumity
Root password               set: **********
User account                set: 2 User(s)
Profile                     set: Profile (desktop)
Audio                       set: pipewire
Kernels                     set: ['linux']
Additional packages         set: []
Network configuration       set: Copy ISO Configuration
Timezone                    set: America/New_York
Automatic time sync (NTP)   set: True
Optional repositories       set: ['multilib']
```

With the inital settings set up, we should select `Save configuration` the scroll down to `Save all` and press enter.  You will be asked where to save your files. Since we won't be able to keep the files permanently (unless someone can tell me where they go upon the first restart), you should save them to the `root` directory. You will need to type `/root` (note the forward slash before `root`). This will help us save our configuration before we go to the next part of this install.

### Drives

Probably the worst part about the installation experience is the `Drive(s)` option. At the time of this writing (January 2023), you might experience a problem with `archinstall` that results in the program crashing.  This is why I wanted you to do all that other stuff (except for `Additional packages`) before coming to this section.

If the program crashes, you can use the following command to get back up to speed for the most part

```bash
archinstall --config user_configuration.json --disk-layout user_disk_layout.json --creds user_credentials.json
```

It should be noted that when you reload the data from the `.json` files:

- `Encrypted password` setting for the disk will be reset to `None` (you don't really need that any way. I'll explain why later.)
- `Root password` setting for root access will be reset to `None`. You will need to re-enter that data.

If the program didn't crash, you'll be asked to select a `BlockDevice`. Typically, you want to select `/dev/sda` since that is where your harddrive should be.  It is possible to apply this to more than one drive, and I'm sure someone on YouTube will demonstrate how to do it, but for now, let's just assume we only have this one drive.

Two new items will appear in our main menu: `Disk layout` and `Encryption password`.

The first option `Disk layout` is important. We will need to use it to set our partitions. There are two options when it comes to Disk layout

- Select what to do with each individual drive (followed by partition usage)
- Wipe all selected drives and use best-effort default partition layout

I'm not going to go into a step-by-step part on that first option. While we could use either opition, if you only have one drive and it is a fresh drive with nothing on it, you should use the `Wipe all selected drives and use best-effort default partition layout`.

The typical Linux sytems has about two to four partitions depending on the configuration.  The first partition will always be the **boot parition** and typically has the `/boot` directory on it.  It is often the smallest partition.  The **main parition** will typically have both the system data on it and the user data.  Some systems will put the system data onto its own partition and the user partition on a separate one.  If you download a lot of software to your system parition, this could be problematic because that system partition will fill up quickly as it will be way smaller than your user partition.  From personal experience, I would not recommend putting system and user paritions on separate partitions unless there is a way to allocate adequate space for the system partition.  The third type of partition is called a **swap parition**. This is typically used for virtual memory and is typically managed automatically.

You will be asked to choose which filesystem your main parition should use. There are four options.

- btrfs
- ext4
- f2fs
- xfs

I'm not familar with those last two items. I do know that ext4 used to be the typical filesystem for Linux up until a few years ago.  It's sort of like NTFS, which if you have any older harddrives you want to read, you'll defintely want to install the `ntfs-3g` package in the additional packages later.  The new file system and the one that we will be using is called **btrfs** (prounced "butter f s"), which stands for *B-Tr*ee *f*ile*s*ystem. Btrfs is a computer storage format that combines a file system based on the *copy-on-write* (COW) principle with a *logical volume manager* (which is not the same as Linux's LVM program).  The advantages of btrfs are scalablity, reliablity, and ease of use.  It's also what ArchLinux recommends.  So we'll select `btrfs` from that list.

The next question asks if you would like to use BTRFS subvolumes with a default structure?  This will create several *mountpoints* which are not the same as partition so that the computer can find stuff. we want to say **yes** to this.

Next, it will ask if you would like to use BTRFS compression. You can say **yes** to that too.

You will return to the main menu. 

If you hover ovedr the `Drive(s)` option you will likely see the list of devices that will be set when the program is done.  I have a 512GB drive installed, so this is what I see.

```text
Device   | Size    | Free Space          | Bus-type
----------------------------------------------------
/dev/sda | 478.9GB | 1031kB+1049kB+335kB | sata
```

If you hover over the `Disk layout` option, you will see two tables at the bottom you should see this.

```text
Device: /dev/sda

  type  |  start |  size  | boot | encrypted | wipe | mountpoint | format |   mount_options
----------------------------------------------------------------------------------------------
primary |  1MiB  | 512MiB | True |   False   | True |   /boot    |  fat32 |
primary | 512MiB |  100%  |      |   False   | True |   None     |  btrfs | ['compress=zstd']

name     | mountpoint | compress | nodatacow
--------------------------------------------
@        | /          |    False |     False
@home    | /home      |    False |     False
```

OK, here's why we do not need to set the `Encryption password`:

1. You don't work for the NSA nor are you on some high priority watch list. Unless you are keeping state secrets on your computer, are completely paranoid (\*cough\*`linux-hardened`\*cough\*), there's a mysterous van parked outside your home that looks like an abandoned food truck that is *totally* "not the FBI", or you are worked someone will break into your house just for the M.2 drive in your computer, there is no need to set this.
2. When you boot up, you will be asked to enter it, which is not the same as your login password, which is super annoying as the starup sequence won't happen unless you enter that password first.

Unless you've attempted to overthrow the federal government in the last few years, there is no reason for you to add an encryption password.

With that said, the three options should look like this.

```text
...
Drive(s)                    set: 1 Drive(s)
Disk layout                 set: 2 Partitions
Encryption password         set: None
...
```

When you are done, save your file configuration again as before.

### Additional packages

Finally, there is a list of packages I recommend that you install. This is the longest part of the install. I'm not going to list them all out. YMMV, but these are defintely essential.

> TODO: clean up this part later. Organize it!

```text
git openssh firefox cowsay ponysay fortune-mod figlet cymatrix mpv bat lsd man-pages man-db os-prober neovim lolcat nyancat python-pip task timew ntfs-3g yt-dlp tmux neofetch noto-fonts noto-fonts-emoji noto-fonts-cjk powerline powerline-fonts htop bashtop awesome-terminal-fonts pango cairo polkit libinput kitty imagemagick jq ttf-liberation clang llvm lldb rust nodejs npm flatpak cmake ninja jupyterlab jupyter-notebook docker zsh jdk-openjdk github-cli gitlab mariadb xclip rtl-sdr ufw nmap nss-ndns cups yarn postgresql postgis bash-completion wireshark-cli exfat-utils unrar weechat weechat-matrix dosbox samba systemd-libs fzf base-devel
```

OK so some of these items aren essential. You could probably do without `mariadb` or `postgresql` if you aren't working on database stuff

#### You need a Login Manager!

> Note: If you forgot to install this, don't worry. It appears that `lightdm` is installed...it sucks but we can chage it later.

There is one other package that you should install that is really important: a **login manager**. This is that program that you need to type in a password before startup.


### Time to launch!

> TODO: I need to make sure this is everything here. I'm trying to remember as much as I can from memory

You will likely be asked once everything is installed if you would like to `chroot` to apply any other changes post-install, since we took care of all the suff we need to do we can say "no", but if we say yes, we might be put in a diffent shell which wel can type `exit`.

We should be ready to go. Type `reboot` to see if we are successful.

Congratulations, you've install Arch Linux on your computer.  Now for all the post-install stuff.

### Post install stuff

> Note: If you are using a tiny computer like a [GPD MicroPC](https://wiki.archlinux.org/title/GPD_MicroPC), you might notice your layout is a bit...sideways.  This is because on small devices, the layout is se to a portrait layout, which is the default for most smartphones. We can fix this by changing a few things later.


The first time you log in you will see this ugly log-in manager called LightDM. I'm no fan of it. We've still got plenty of command-line stuff to do like installing `yay`, so we're gonna go through "the back door". Not a literal "backdoor", but more like another terminal interface.  To do this, I need to use `CTRL + ALT + F2`

Here we are greeted with a typical prompt.

```text
[luz@lumity ~]$
```

But don't get too comfy with that. We need to install [`yay`](https://github.com/Jguer/yay)

First thing, let's make sure we have everything installed so far is up todate. Because we are using `sudo` the first time, we'll the the ["Uncle Ben" speech](https://en.wikipedia.org/wiki/With_great_power_comes_great_responsibility) for the first time.

```bash
pacman -Syyu
```

We should also make some folders in the home directory. We can use a `for` loop in `bash` to do all this in one command.

```bash
cd ~
for d in bin Desktop Documents Downloads Help Music Pictures Projects Public Sandbox Templates Videos; do mkdir $d; done
```

We already installed `git` and `base-devel` when we installed our additional packages. But if you haven't, now is the time to do it. We will be using it a lot. This will also install the `go` package which will install the [Go Language](https://go.dev/) in the process.

```bash
sudo pacman -S --needed git base-devel
cd Downloads
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
```

With `yay` installed, we can now install packages from the [ArchLinux User Repository](https://aur.archlinux.org/) (AUR).  I'm thinking of using [`ly`](https://github.com/fairyglade/ly) as the login/desktop manager.

```bash
yay -S ly
```

Two things to note about `yay`

1. You'll likely be asked if you want to see "diffs". That's asking if you want to see the difference between that and some other files. Generally, you should just say "n" (no).
2. You don't use `sudo` with `yay`, but you will be asked later to enter your root password to install things.

> TODO: Finish the `ly` setup.

Eariler we had installed a package called `bash_completion`. This will enable tab completion of commands. To enable it, you can add this line to your `~/.bashrc` file.

First we need to open `~/.bashrc` in Neovim.

```bash
nvim ~/.bashrc
```

```bash
[[ ${PS1} && -f "/usr/share/bash-completion/bash_completion" ]] && share "/usr/share/bash-completion/bash_completion"
```

While we are at it, we should probably add a line to have Bash recoginze any bash aliases we add to a file called `~/.bash_aliases`.  Add this line before the line that we wrote to enable `bash_completion`.

```bash
[[ -f "$HOME/.bash_aliases" ]] && source "$HOME/.bash_aliases"
```

We should also probably modify our **pager** program to be more user friendly. The default pager program is `less`, but it only uses the `-R` argument. Add these two lines to `~/.bashrc` to fix that.

```bash
export PAGER="less"
export LESS="-eFMXR"
```

Once that is done, we can press `ESC` and type `:wq` to save and quit Neovim.  We use Neovim because it uses a programming language called Lua which is much eaiser to use than VimScript and can be use to write programs elsewhere.

Finally, let's reload `bash` to use the new settings in `~/.bashrc`

```bash
exec bash
```

You should be able to use the `TAB` key to do command completions.

> Note: If you would like to do some more shell scripting, consider installing `shfmt` and `shellcheck` later. The reason why we didn't include them in the Additional Packages is that `shellcheck` needs to use a language called Haskell which might not work on older systems. YMMV.

> Note: Bash completion is included in my `.bashrc` file in my dotfiles project. We'll use `git` to clone it later and overwrite your `./bashrc` file if you want.

Let's also enable SSH while we are here so we can work on this machine remotely.  

```bash
sudo systemctl enable --now sshd
```

> Note: You should disable the `sshd` daemon whenever you are not using it so that outside devices cannot attempt to get in.

To look up the IP address to get into the device, use `ip addr`.  Since this is a wireless connect, we need to look for the IP address that `wlan0` is using which is right next to the `inet` heyword.

```text
...
4: wlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    link/ether aa:bb:cc:dd:ee:ff brd ff:ff:ff:ff:ff:ff
    inet 192.168.0.nnn/24 metric 600 brd 192.168.0.255 scope global dynamic wlan0
       valid_lft 4130sec preferred_lft 4130sec
    inet6 fe80::aaaa:bbbb:cccc:dddd/64 scope link 
       valid_lft forever preferred_lft forever
```
Suppose Luz wants to access her computer on the home network but from Amity's computer.  Amity uses Linux so Luz can log in with the following command

```bash
ssh luz@192.168.0.nnn     # where nnn is a number
```

The first time she has logged into this new machine, she will be asked if she want to continue connecting to this device because the authenticy of the host cannot be established.  Since this device does belong to her, she would type in `yes` (not `y`) then enter the user password.

When Luz is done with her work, she types `exit` to close the connection.

Luz tells Amity that Amity can access Luz's computer, she just needs to set up the SSH key.  So Amity logs on to her computer to access Luz's computer.  She will likely get the same questions as this is the first time `amity` has access the `lumity` computer.  Since she knows the password to log into the machine she can access the computer.  But she is a clever girl, and logs back out.

On her computer, Amity creates an SSH Key with `ssh-keygen`

```bash
ssh-keygen -t ed25519 -C "$(whoami)@$(uname -n)-$(date -I)" -f ~/.ssh/lumity_ed25519
```

This command will create an SSH Key, encrypted with ED25519 encryption, creating a private key file at `~/.ssh/lumity_ed25519` and a public key file `~/.ssh/lumity_ed25519.pub`.  The `-C` part adds a comment that is a short note stating who created the key (using `whoami`), on what machine (using `uname -n`), and when it was created (using a timestamp generated by `date -I`).  This comment will be added to the end of the public key file and might look like `ablight@blightind-2023-01-21`.

Amity then copys the public key to the machine that Luz set up using this command

```bash
ssh-copy-id -i ~/.ssh/lumity_ed25519.pub amity@192.168.0.nnn
```

Amity then enters her password to access `lumity` and then uses the following two commands to start the `ssh-agent` in the background and add her private key to her SSH key ring.  (Yeah, this is a crappy "fanfic", isn't it! On the other hand, it's probably better than what you've read on AO3. lol)

```bash
eval "$(ssh-agent -s)"
# Should return something like "Agent pid 1234546"
ssh-add ~/.ssh/lumity_ed25519
# "Identity added to /home/ablight/.ssh/lumity_ed25519 (ablight@blightind-2023-01-21)"
```

From now on, Amity should be able to log into `lumity` without needt to remember her password.

> Tip: In case that doesn't work out, adding a alias to your `~/.bash_aliases` file to log in with out a password can also be done.
>
> `alias lumity="ssh amity@192.168.0.nnn -i ~/.ssh/lumity_ed25519"`
> 
>
> Later we'll figure out how to get Avahi set up so we can change that `192.168.0.nnn` part to `lumity` or `lumity.local`.

Better documentation of this process can be found in the [Github docs](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent)

Earlier we installed a package called `powerline`, however we can't use it yet untill we configure a terminal called `kitty` which supports special fonts that include glyphs that appear as icons.

> TODO: Instructions to set up `kitty` and `powerline` and `p10k`. We will need to repeat this process later when we switch to `zsh`.

Let's use `yay` to install `nvm` since we'll be doing some node development.  This is just to make sure that if `nodejs` gets a new version, but the project we are working on still needs to work in a more stable environment, that we can do it.

```bash
yay -S nvm
```

After installing `nvm`, you will need to open `~/.bashrc` and add this line to the end of the file. This MUST be the last line. When we add `powerline` later, all the `powerline` stuff will need to be put right before this line.  We will also have to add a similar line to our `~/.zshrc` file when we migrate from `bash` to `zsh`.

```bash
source /usr/share/nvm/init-nvm.sh
```

