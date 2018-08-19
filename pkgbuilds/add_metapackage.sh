#!/usr/bin/env bash

set -e

pkgname=$1
pkgdesc=$2
depends=$3

if [ -f pkg/$pkgname/PKGBUILD ]; then
	echo "Non-empty folder with the name $pkgname found. Aborting."
	exit 1
fi


mkdir -p pkg/$pkgname && cd pkg/$pkgname
touch PKGBUILD

cat >>PKGBUILD <<EOF
# Maintainer: Tibor Pilz <tbrpilz@googlemail.com>
pkgname=$pkgname
pkgver=0.0.1
pkgrel=1
pkgdesc=$pkgdesc
arch=('any')
url="https://github.com/lnc-lt/arch-lnclt-pkgbuilds"
license=('MIT')
depends=(
EOF

for dependency in $depends
do
	printf "\t'$dependency'\n" >> PKGBUILD
done

echo ")" >> PKGBUILD
