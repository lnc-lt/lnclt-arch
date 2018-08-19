#!/usr/bin/env bash

pkg="pkg"
repo="repo"
root=$PWD

cd "$root/$pkg"

# Get absolute paths for package locations
for package in $(readlink -f $(ls))
do
	#Create package
	cd $package
	makepkg -s --noconfirm

	#Add package information to repo
	repo-add "$root/$repo/lnclt.db.tar.xz" *.pkg.tar.gz

	#Add package to repo
	mv *.pkg.tar.gz "$root/$repo/"

	#Clean up
	rm -rf {pkg,src}
done
