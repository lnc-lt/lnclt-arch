#!/bin/bash
# WARNING: this script will destroy data on the selected disk.
# This script can be run by executing the following:
#   curl -sL https://git.io/vAoV8 | bash
set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

REPO_URL="https://arch.lnc.lt/repo"

hostname=""
user=""
password=""
device=""
dryrun=false

### Parse flags ###
while getopts ":n:u:p:d:rh" opt; do
	case $opt in
		n)
			hostname=$OPTARG
			;;
		u)
			user=$OPTARG
			;;
		p)
			password=$OPTARG
			;;
		d)
			device=$OPTARG
			;;
		r)
			dryrun=true
			;;
		h)
			echo "Arch Linux installation script"
			echo "-n [name]: hostname"
			echo "-u [user]: Admin user"
			echo "-p [password]: Admin password"
			echo "-d [device]: Disk device"
			echo "-r: Dry run"
			echo "-h: Help"
			echo "Example usage: ./setup.sh -u admin -p Hunter2 -d /dev/sda"
			echo "Missing parameters are queried interactively, so ./setup.sh suffices"
			exit 0
			;;
		\?)
			echo "Invalid option: -$OPTARG" >&2
			exit 1
			;;
		:)
			echo "Option -$OPTARG requires an argument." >&2
			exit 1
			;;
	esac
done

### Get missing information interactively ###
if [[ -z "$hostname" ]]; then
  hostname=$(dialog --stdout --inputbox "Enter hostname $hostname" 0 0) || exit 1
  clear
  : ${hostname:?"hostname cannot be empty"}
fi

if [[ -z "$user" ]]; then
	user=$(dialog --stdout --inputbox "Enter admin username" 0 0) || exit 1
	clear
	: ${user:?"user cannot be empty"}
fi

if [[ -z "$password" ]]; then
	password=$(dialog --stdout --passwordbox "Enter admin password" 0 0) || exit 1
	clear
	: ${password:?"password cannot be empty"}
	password2=$(dialog --stdout --passwordbox "Enter admin password again" 0 0) || exit 1
	clear
	[[ "$password" == "$password2" ]] || ( echo "Passwords did not match"; exit 1; )
fi

if [[ -z "$device" ]]; then
	devicelist=$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tac)
	device=$(dialog --stdout --menu "Select installtion disk" 0 0 0 ${devicelist}) || exit 1
	clear
fi

if $dryrun; then
	echo "This would happen:"
	echo "$device would get repartitioned, with a 192MiB fat32 boot partition"
	echo "and and btrfs partition spanning the rest of the device."
	echo "Pacstrap would install the lnclt package group to the newly created device."
	exit 0
fi

### Set up logging ###
exec 1> >(tee "stdout.log")
exec 2> >(tee "stderr.log")

timedatectl set-ntp true

### Prepare target disk device partitioning ###
parted --script "${device}" -- mklabel gpt \
  mkpart ESP fat32 1Mib 129MiB \
  set 1 boot on \
  mkpart primary btrfs 192Mib 100%

# Simple globbing was not enough as on one device I needed to match /dev/mmcblk0p1 
# but not /dev/mmcblk0boot1 while being able to match /dev/sda1 on other devices.
part_boot="$(ls ${device}* | grep -E "^${device}p?1$")"
part_root="$(ls ${device}* | grep -E "^${device}p?2$")"

### Wipe partitions and create file systems
wipefs "${part_boot}"
wipefs "${part_root}"
mkfs.vfat -F32 "${part_boot}"
mkfs.btrfs -f "${part_root}"

### Mount partitions
mount "${part_root}" /mnt
mkdir /mnt/boot
mount "${part_boot}" /mnt/boot

# ### Install and configure the basic system ###
pacstrap /mnt base base-devel lnclt-desktop
genfstab -t PARTUUID /mnt >> /mnt/etc/fstab
echo "${hostname}" > /mnt/etc/hostname

### Set up repository and dependencies ###

cat >>/mnt/etc/pacman.conf <<EOF
[lnclt]
SigLevel = Optional TrustAll
Server = $REPO_URL
EOF

arch-chroot /mnt bootctl install

cat <<EOF > /mnt/boot/loader/loader.conf
default arch
EOF

cat <<EOF > /mnt/boot/loader/entries/arch.conf
title    Arch Linux
linux    /vmlinuz-linux
initrd   /initramfs-linux.img
options  root=PARTUUID=$(blkid -s PARTUUID -o value "$part_root") rw
EOF

# Create locale and set system language
arch-chroot /mnt bash -c "ln -sf /usr/share/zoneinfo/Europe/Berlin /etc/localtime \
	&& echo \"LANG=en_US.UTF-8\" > /etc/locale.conf \
  && sed 's/#en_US/en_US/' -i /etc/locale.gen \
	&& locale-gen"

# Create admin user and set up password and default shell
arch-chroot /mnt bash -c "chsh -s /usr/bin/zsh\
	&& useradd -mU -s /usr/bin/zsh -G wheel,uucp,video,audio,storage,games,input "$user"\
	&& echo '$user:$password' | chpasswd \
	&& echo 'root:$password' | chpasswd"
