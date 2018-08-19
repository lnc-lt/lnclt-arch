#!/usr/bin/env bash

root=$PWD
pkg="$root/pkg"
repo="$root/repo"

chroots="$root/chroots"
packages=${@:-pkg/*}

# Create chroot if not existing
[[ -d "$chroots/root" ]] || mkarchchroot -C /etc/pacman.conf "$chroots/root" base base-devel

# Build packages in clean chroot and copy to repo location
for package in $packages; do
	cd "$package"
	rm -f *.pkg.tar.xz
	makechrootpkg -cur $chroots
	repo-add "$repo/lnclt.db.tar.xz" *.pkg.tar.xz
	cp *.pkg.tar.xz "$repo/"
	cd -
done
