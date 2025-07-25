{ lib, ... }:
{
  disko.devices = {
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        "relatime"
        # "noatime"
        "mode=755"
        "nosuid"
        "nodev"
      ];

      # mountOptions = [
      #   "size=2G"
      #   "defaults"
      #   "mode=755"
      # ];

    };

  };

  disko.devices.disk = {
    primary = {
      type = "disk";
      device = lib.mkDefault "/dev/sda";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            priority = 1;
            name = "ESP";
            start = "1M";
            end = "1G";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
          internal = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = [
                "-L"
                "internal"
                "-f"
              ];
              subvolumes = {
                # "/root" = {
                #   mountpoint = "/";
                #   mountOptions = [
                #     "subvol=root"
                #     "noatime"
                #   ];
                # };
                # "/home" = {
                #   mountpoint = "/home";
                #   mountOptions = [
                #     "subvol=home"
                #     "noatime"
                #   ];
                # };
                "/nix" = {
                  mountpoint = "/nix";
                  mountOptions = [
                    "subvol=nix"
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/persist" = {
                  mountpoint = "/persist";
                  mountOptions = [
                    "subvol=persist"
                    "compress=zstd"
                    "noatime"
                  ];
                };
                "/log" = {
                  mountpoint = "/var/log";
                  mountOptions = [
                    "subvol=log"
                    "compress=zstd"
                    "noatime"
                  ];
                };
                ## also have to worry about disabling cow and other stuff on btrfs
                # using
                # "/swapspace" = {
                #   mountpoint = "/swapspace";
                #   mountOptions = [
                #     "subvol=swapspace"
                #     "compress=zstd"
                #     "noatime"
                #     "discard"
                #   ];
                # };
              };
            };
          };
        };
      };
    };
  };
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/var/log".neededForBoot = true;
}
