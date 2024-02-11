## Description
Bash script to create swap in Debian, with option to provide additional packages to be installed.
Swap size is either automatically determined by RAM amount available on the machine 
or by optional argument on the script.

## Motivation
In my homelab withing Proxmox VE I do have minimal Debian 12 cloud-init image as template.
It has bare minimum required to boot a VM, so that cloud-init image is minimal as possible.

This script is for post-installation to quickly create appropriate swap and optionally install additional
packages.

## Options
- size => default's to 2x of RAM assigned, optionally can be set to custom value by script using argument `-s NUMERIC_VALUE`
- packages => list of comma separated packages provided trough script argument as `-p rsync,git,curl`

## Usage 

### Default
```sh
wget -qLO - https://github.com/valicm/debian-pve-script/raw/main/debian-pve-script.sh | bash
```

### Custom swap size 8GB, with git and rsync
```sh
wget -qLO - https://github.com/valicm/debian-pve-script/raw/main/debian-pve-script.sh | bash -s -- -s 8 -p git,rsync
```

### Running as sudo user
```sh
wget -qLO - https://github.com/valicm/debian-pve-script/raw/main/debian-pve-script.sh | sudo bash -s -- -s 8 -p git,rsync
```