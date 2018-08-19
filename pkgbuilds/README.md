## PKGBUILDS for lnc.lt custom arch repository

This repository contains PKGBUILDs for all the packages on the https://arch.lnc.lt/repo repository. The packages are mostly meta-packages, allowing for easy, modular scaffolding of different Arch Linux installs.

### Usage

* Via Docker
  
  #### Dependencies:
	 * Docker

  Run `docker run -v "$PWD/repo:/repo" lnclt/arch-repo`.

* Per hand

  #### Dependencies:
	  * Arch Linux
	  * base-devel, wget, and a non-root user for installing packages
	  * aurutils (aur)

  Run `./build_packages.sh`. Ensure the proper pkg and repo paths are set inside the script.
  By default, it assumes a `pkg` folder full of package folders, which in turn contain the PKGBUILDS,
  as well as a `repo` folder, which is where the repostiory files and package binaries are saved.
