#!/usr/bin/env bash

set -e

pkgname=$1
pkgdesc=$2
depends=$3

if [ -f pkg/$pkgname.PKGBUILD ]; then
	echo "PKGBUILD with the name $pkgname.PKGBUILD found. Aborting."
	exit 1
fi

pkg="$pkgname.PKGBUILD"

cd pkg

touch "$pkg"

cat >>$pkg <<EOF
# Maintainer: Tibor Pilz <tbrpilz@googlemail.com>
pkgname="$pkgname"
pkgver=0.0.1
pkgrel=1
pkgdesc="$pkgdesc"
arch=('any')
url="https://github.com/lnc-lt/arch-lnclt-pkgbuilds"
license=('MIT')
depends=(
EOF

for dependency in $depends
do
	printf "\t'$dependency'\n" >> $pkg
done

echo ")" >> $pkg
