#!/bin/bash
# WARNING: this script will destroy data on the selected disk.
set -uo pipefail
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

REPO_URL="https://arch.lnc.lt/repo"

hostname=$(dialog --stdout --inputbox "Please enter hostname:" 0 0) || exit 1
clear
: ${hostname:?"Hostname cannot be empty."}

user=$(dialog --stdout --inputbox "Please enter admin username:" 0 0) || exit 1
clear
: ${user:?"Admin username cannot be empty."}

password=$(dialog --stdout --passwordbox "Please enter admin password" 0 0) || exit 1
clear
: ${password:?"Admin password cannot be empty."}
password2=$(dialog --stdout --passwordbox "Please enter admin password again" 0 0) || exit 1
clear
[[ "$password" == "$password2" ]] || ( echo "Sorry, the passwords did not match"; exit 1; )

devicelist=$(lsblk -dplnx size -o name,size | grep -Ev "boot|rpmb|loop" | tac)
device=$(dialog --stdout --menu "Select installtion disk" 0 0 0 ${devicelist}) || exit 1
clear

### Set up logging ###
exec 1> >(tee "stdout.log")
exec 2> >(tee "stderr.log")

timedatectl set-ntp true

### Setup the disk and partitions ###
swap_size=$(free --mebi | awk '/Mem:/ {print $2}')
swap_end=$(( $swap_size + 129 + 1 ))MiB

parted --script "${device}" -- mklabel gpt \
  mkpart ESP fat32 1Mib 129MiB \
  set 1 boot on \
  mkpart primary linux-swap 129MiB ${swap_end} \
  mkpart primary ext4 ${swap_end} 100%

# Simple globbing was not enough as on one device I needed to match /dev/mmcblk0p1
# but not /dev/mmcblk0boot1 while being able to match /dev/sda1 on other devices.
part_boot="$(ls ${device}* | grep -E "^${device}p?1$")"
part_swap="$(ls ${device}* | grep -E "^${device}p?2$")"
part_root="$(ls ${device}* | grep -E "^${device}p?3$")"

wipefs "${part_boot}"
wipefs "${part_swap}"
wipefs "${part_root}"

mkfs.vfat -F32 "${part_boot}"
mkswap "${part_swap}"
mkfs.f2fs -f "${part_root}"

swapon "${part_swap}"
mount "${part_root}" /mnt
mkdir /mnt/boot
mount "${part_boot}" /mnt/boot

### Install and configure the basic system ###
cat >>/etc/pacman.conf <<EOF
[lnclt]
SigLevel = Optional TrustAll
Server = $REPO_URL
EOF

# Update sources
sudo pacman -Sy

pacstrap /mnt base base-devel lnclt-base lnclt-desktop lnclt-devel
genfstab -t PARTUUID /mnt >> /mnt/etc/fstab
echo "${hostname}" > /mnt/etc/hostname

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

echo "LANG=en_US.UTF-8" > /mnt/etc/locale.conf

arch-chroot /mnt useradd -mU -s /usr/bin/zsh -G wheel,uucp,video,audio,storage,games,input "$user"
arch-chroot /mnt chsh -s /usr/bin/zsh

arch-chroot /mnt echo "$user:$password" | chpasswd
arch-chroot /mnt echo "$root:$password" | chpasswd



# echo "$user:$password" | chpasswd --root /mnt
# echo "root:$password" | chpasswd --root /mnt
