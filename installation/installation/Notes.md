When in doubt, follow the [Arch installation guide](https://wiki.archlinux.org/index.php/Installation_guide)

# Preparation/Base installation
This _needs_ to happen from another system.

1. boot from arch iso
1. identify and prepare disk using `lslblk` and `fdisk`. for this purpose, the device found by `lsblk` is `/dev/sda`.
  1. `fdisk /dev/sda` to create partition table and root/boot partitions
		1. `g` to create GPT partition table
		1. Create boot partition:
			1. `n` to add new partition.
			1. `Enter` to keep default partition number (1)
			1. `Enter` to keep default first sector.
			1. `+1G` to set partition size to 1 Gb.
			1. `Enter` to confirm new partition
			1. `t` to change partition type
			1. `1` to select the previously created partition
			1. `1` to choose `EFI System`
		1. Create root partition:
			1. `n` to add new partition.
			1. `Enter` to keep default partition number (2)
			1. `Enter` to keep default first sector
			1. `Enter` to keep default last sector
			1. `Enter` to confirm new partition
		1. `w` to write changes to `/dev/sda` and exit
2. format disks
 1. `mkfs.fat -F32 /dev/sda1` to format boot to fat32
 1. `mkfs.btrfs /dev/sda2` to format root to btrfs
	 1. `btrfs subvol create /mnt/root` to create root subvolum
	 1. `btrfs subvol list /mnt` to get subvolume id
	   * example output: `ID 259 gen 10 top level 5 path root` (id in this case is 259)
	 2. `btrfs subvol set-default 259 /mnt` to set newly created root subvolume as default
	 3. `umount /mnt && mount /dev/sda2 /mnt` to un- and then remount the root filesystem (now with the subvolume `root` as default

3. mount disks
 1. `mount /dev/sda2 /mnt` to mount root partitition
 1. `mkdir /mnt/boot` to create boot mountpoint
 1. `mount /dev/sda1 /mnt/boot` to mount boot to root mountpoint

4. install base system
 1. (optional) sort mirror list
 1. `pacstrap /mnt base base-devel` to install arch base and base-devel groups to `/mnt`

5. generate fstab
 1. `genfstab -U /mnt >> /mnt/etc/fstab`

# System configuration
This should happen using chroot.

`arch-chroot /mnt` to chroot into the newly created system. Then:

1. Timezone & Localization
 1. `ln -sf /usr/share/zoneinfor/Europe/Berlin /etc/localtime` to set TZ to Berlin
 1. `hwclock --systohc` to generate `/etc/adjtime`
 1. Language (assuming `LANGUAGE=en_US`)
  1. `nano /etc/locale.gen` and uncomment the specific line
	1. `locale-gen`
	1. `echo 'LANG=en_US.UTF8' > /etc/locale.conf`

2. Network (assuming `HOSTNAME=arch`)
 1. `echo 'arch' > /etc/hostname'` to set hostname
 2. To create hosts entries:
		
		`echo <<EOT >> /etc/hosts'
		127.0.0.1		localhost
		::1					localhost
		127.0.1.1		arch.localdomain arch
		EOT` 
