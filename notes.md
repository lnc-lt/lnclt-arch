# Custom Arch build

### metapackages and custom repository
We can use arch metapackages to include the actual packages we want to install.
For a custom repository, named 'lnclt', for instance, there could be 'lnclt-base',
'lnclt-desktop', 'lnclt-devel' metapackages each containing the packages needed.
More info under a forum post by  "mdaffin".

### metapackage generation
Instead of relying on a host arch, metapackages can be generated using a docker image
that's based on Arch and build helper tools.

### startup script
This should be minimal, so that it can be `curl`ed and executed on a live system.
The usual stuff needs to be done, partitioning, setting the local, hostname et cetera.
Then, the custom repo defined earlier should be added to the pacman.conf and then installing 
the system is as easy as `pacstrap /mnt lnclt-base lnclt-desktop` or similar.

### packer
Instead of spinning up a vm everytime there are changes to the script or the custom repo,
or even worse booting from a live stick just to test, packer can be used to automatically
generate VMs based on a configuration file. After startup, the custom install script can be
passed to the VM instance so that the image generation is fully automatic.


# Todo

 * finalize meta-packages
 * create packages for configuration
 * integrate dotfiles with a meta-package
 * set up CI
  * integrate CI for dockerfile
	* integrate CI for installation script
	* integrate CI for resulting arch image
 * set up repository hosting
 * generate documentation for arch repository
  - autogenerate images of finished arch
	- browser emulation of host system (?)
 * write out readmes for the code and configs
 * find a way to package everything for widespread use

 * containerize different services
	 - script hosting
	 - repository hosting
	 - package generation
	 - image/ package repository documentation generation
	   (those don't have to be all split up)
 * automate adding new packages 
