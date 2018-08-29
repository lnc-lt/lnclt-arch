#!/bin/bash

set -e
set -x

if [ -e /dev/vda ]; then
  device=/dev/vda
elif [ -e /dev/sda ]; then
  device=/dev/sda
else
  echo "ERROR: There is no disk available for installation" >&2
  exit 1
fi
export device

memory_size_in_kilobytes=$(free | awk '/^Mem:/ { print $2 }')
swap_size_in_kilobytes=$((memory_size_in_kilobytes * 2))

sfdisk "$device" <<EOF
label: dos
size=2GiB, type=82
					 type=83, bootable
EOF
mkswap "${device}1"
mkfs.ext4 "${device}2"
mount "${device}2" /mnt

curl -fsS https://www.archlinux.org/mirrorlist/?country=DE | grep '^#Server' \
	| head -n 50 | sed 's/^#//' > /etc/pacman.d/mirrorlist

cat >>/etc/pacman.conf <<EOF
[lnclt]
SigLevel = Optional TrustAll
Server = https://arch.lnc.lt/repo
EOF

pacstrap /mnt base lnclt-desktop lnclt-devel

genfstab -p /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash
