#!/bin/sh
# set -e # instead of chaining &&s
# # cd / # this is on iso so doesn't matter where it is, will get deleted anyway
# # sudo git clone https://github.com/sourajit02/nixcfg
# # cd nixcfg
# sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko/latest -- --mode destroy,format,mount --yes-wipe-all-disks ./hosts/hbox/disks.nix
# sudo nixos-generate-config --no-filesystems --root /mnt --force
# sudo cp /mnt/etc/nixos/hardware-configuration.nix ./hosts/hbox/
# sudo nixos-install --root /mnt -I nixos-config=./configuration.nix --no-root-passwd
# # interactive
# sudo passwd root
# sudo passwd s
# cd /users/s/config
# if [ -d "nixcfg" ]; then
#     sudo rm -rf nixcfg
# fi
# git clone https://github.com/sourajit02/nixcfg
# cd nixcfg
# sudo nixos-generate-config --no-filesystems --force --show-hardware-config > hardware-configuration.nix
# sudo chown -R s:root .
# su - s
# # su - s -c "cd config && pwd"
# # su - s -c "git clone https://github.com/sourajit02/nixcfg"
# # su - s -c "cd nixcfg"
# # su - s -c "sudo nixos-generate-config --show-hardware-config > hardware-configuration.nix"
sudo nix run github:nix-community/nixos-anywhere -- --flake .#hbox --generate-hardware-config nixos-generate-config ./hosts/hbox/hardware-configuration.nix --local
