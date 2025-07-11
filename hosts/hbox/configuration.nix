{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    # ./hardware-configuration.nix
    ./disks.nix
  ];

  system.stateVersion = "25.11"; # never change this
  users.users.root.initialPassword = "password"; # install-script will prompt change for root and s
  security.sudo.wheelNeedsPassword = false;
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Limit the number of generations to keep
  boot.loader.systemd-boot.configurationLimit = 10;
  # Perform garbage collection weekly to maintain low disk usage
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 1w";
  };
  # Optimize storage
  # https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-auto-optimise-store
  nix.settings.auto-optimise-store = true;

  # nix.nixPath = [ "/users/s/config/nixcfg" ];
  nix.nixPath = [ "/home/s/nixcfg" ];
  networking.hostName = "hbox";
  networking.networkmanager.enable = true;
  services.printing.enable = true;
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };
  time.timeZone = "Australia/Sydney";
  console.keyMap = "colemak";
  services.xserver = {
    enable = true;
    displayManager.startx.enable = true;
    xkb = {
      layout = "us";
      variant = "colemak";
    };
  };
  # system.copySystemConfiguration = true; # cannot be used with nixos-anywhere
  services.openssh.enable = true;
  programs.firefox.enable = true;

  # Enable the Flakes feature and the accompanying new nix command-line tool
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  environment.systemPackages = with pkgs; [
    git # order matters, so git is first
    curl
    wget
    helix
    yazi
    alacritty
    nushell
    niri
  ];
  programs.niri.enable = true;
  # programs.nushell.enable = true;
  hardware.graphics.enable = true; # vm issues?
  # Set the default editor to vim
  environment.variables.EDITOR = "helix";

  users.users.s = {
    home = "/home/s";
    isNormalUser = true;
    initialPassword = "password";
    shell = pkgs.nushell;
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
    ];
    createHome = true;
  };

  # subvolumes other than root will still be persisted
  # check disko for what they are

  # boot.initrd.systemd.services.btrfs-root-cleanup = {
  #   description = "Clean up old btrfs root snapshots";
  #   wantedBy = [ "initrd.target" ];
  #   after = [ "systemd-udev-settle.service" ];
  #   before = [ "sysroot.mount" ];
  #   unitConfig.DefaultDependencies = false;
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = true;
  #   };
  #   script = ''
  #     mkdir -p /btrfs_tmp
  #     mount /dev/disk/by-partlabel/disk-primary-internal /btrfs_tmp

  #     if [[ -e /btrfs_tmp/root ]]; then
  #       mkdir -p /btrfs_tmp/old_roots
  #       timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
  #       mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
  #     fi

  #     delete_subvolume_recursively() {
  #         IFS=$'\n'
  #         for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
  #             delete_subvolume_recursively "/btrfs_tmp/$i"
  #         done
  #         btrfs subvolume delete "$1"
  #     }

  #     for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +7); do
  #         delete_subvolume_recursively "$i"
  #     done

  #     btrfs subvolume create /btrfs_tmp/root
  #     umount /btrfs_tmp
  #   '';
  # };

  # boot.initrd.postResumeCommands = lib.mkAfter ''
  #   mkdir /btrfs_tmp
  #   mount /dev/disk/by-partlabel/disk-primary-internal /btrfs_tmp

  #   if [[ -e /btrfs_tmp/root ]]; then
  #     mkdir -p /btrfs_tmp/old_roots
  #     timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
  #     mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
  #   fi

  #   delete_subvolume_recursively() {
  #       IFS=$'\n'
  #       for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
  #           delete_subvolume_recursively "/btrfs_tmp/$i"
  #       done
  #       btrfs subvolume delete "$1"
  #   }

  #   for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +7); do
  #       delete_subvolume_recursively "$i"
  #   done

  #   btrfs subvolume create /btrfs_tmp/root
  #   umount /btrfs_tmp
  # '';

  boot.initrd.systemd.enable = true;
  preservation = {
    enable = true;
    preserveAt."/persist" = {
      directories = [
        "/var/lib/nixos"
      ];
      files = [
        # "/etc/machine-id"
      ];
    };
  };

  # environment.persistence."/persist" = {
  #   hideMounts = true;
  #   directories = [
  #     "/var/lib/nixos"
  #     "/var/lib/bluetooth"
  #     "/var/lib/systemd/coredump"
  #     "/var/lib/systemd/timers"
  #     "/etc/NetworkManager/system-connections"
  #     # {
  #     #   directory = "/var/lib/colord";
  #     #   user = "colord";
  #     #   group = "colord";
  #     #   mode = "u=rwx,g=rx,o=";
  #     # }
  #   ];
  #   files = [

  #     # "/etc/machine-id"
  #     # {
  #     #   file = "/etc/nix/id_rsa";
  #     #   parentDirectory = {
  #     #     mode = "u=rwx,g=,o=";
  #     #   };
  #     # }

  #   ];
  #   # do not use home-manager's impermanence module as it comes with fuse performance penalty
  #   users.s = {
  #     directories = [
  #       # mounting issues, don't persist for now
  #       # https://github.com/nix-community/impermanence/pull/243
  #       # ".local/share/Trash"
  #       "nixcfg"
  #     ];
  #     files = [
  #     ];
  #   };
  # };
}
