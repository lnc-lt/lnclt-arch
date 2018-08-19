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
	makechrootpkg -cur $chroots

	#Add package information to repo
	repo-add "$repo/lnclt.db.tar.xz" *.pkg.tar.xz

	#Add package to repo
	cp *.pkg.tar.xz "$repo/"
done
