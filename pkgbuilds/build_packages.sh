#!/usr/bin/env bash

root=$PWD
pkg="$root/pkg"
repo="$root/repo"

chroots="$root/chroots"
packages=${@:-pkg/*}

# Build packages in clean chroot and copy to repo location
for package in $packages; do
	cd "$package"
	rm -f *.pkg.tar.gz
	makepkg -c -s
	repo-add "$repo/lnclt.db.tar.xz" *.pkg.tar.gz
	cp *.pkg.tar.gz "$repo/"
	cd -
done
