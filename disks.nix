{ ... }:
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/sda";
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
                  "/root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "subvol=root"
                      "noatime"
                    ];
                  };
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

                  "/users" = {
                    mountpoint = "/users";
                    mountOptions = [
                      "subvol=users"
                      "noatime"
                    ];
                  };
                  "/users/s" = {
                    mountpoint = "/users/s";
                    mountOptions = [
                      "subvol=s"
                      "noatime"
                    ];
                  };
                  "/users/s/home" = {
                    mountpoint = "/users/s/home";
                    mountOptions = [
                      "subvol=s@home"
                      "noatime"
                    ];
                  };
                  "/users/s/config" = {
                    mountpoint = "/users/s/config";
                    mountOptions = [
                      "subvol=s@config"
                      "noatime"
                    ];
                  };
                };
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
