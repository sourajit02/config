#!/bin/sh
set -e # instead of chaining &&s
# cd /
# sudo git clone https://github.com/sourajit02/nixcfg
# cd nixcfg
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount ./disks.nix
sudo nixos-generate-config --no-filesystems --root /mnt
sudo cp /mnt/etc/nixos/hardware-configuration.nix .
sudo nixos-install --root /mnt -I nixos-config=./configuration.nix
