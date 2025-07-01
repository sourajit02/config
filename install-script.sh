#!/bin/sh
set -e # instead of chaining &&s
# cd / # this is on iso so doesn't matter where it is, will get deleted anyway
# sudo git clone https://github.com/sourajit02/nixcfg
# cd nixcfg
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount --yes-wipe-all-disks ./disks.nix
sudo nixos-generate-config --no-filesystems --root /mnt
sudo cp /mnt/etc/nixos/hardware-configuration.nix .
sudo nixos-install --root /mnt -I nixos-config=./configuration.nix --no-root-passwd
su - s
cd config
git clone https://github.com/sourajit02/nixcfg
cd nixcfg
sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix  
# interactive
sudo passwd root
sudo passwd s
