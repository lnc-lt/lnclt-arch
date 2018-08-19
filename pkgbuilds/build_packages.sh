#!/usr/bin/env bash

root=$PWD
pkg="$root/pkg"
repo="$root/repo"
chroots="$root/chroots"

cd "$pkg"

echo $PWD

# Get absolute paths for package locations
for package in $(ls)
do
	#Create package
	cd $package
	echo $package
	echo "$$$$$$$$$$$$$$$$$$$$$$$$$$$"
	wait 5
	makechrootpkg -cur $chroots

	#Add package information to repo
	repo-add "$repo/lnclt.db.tar.xz" *.pkg.tar.xz

	#Add package to repo
	mv *.pkg.tar.xz "$repo/"

	##Clean up
	#rm -rf {pkg,src}
done
