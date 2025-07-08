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
    trash-cli
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

  boot.initrd.postResumeCommands = lib.mkAfter ''
    echo "DEBUG: postResumeCommands starting" >> /dev/kmsg
      mkdir /btrfs_tmp
      mount /dev/disk/by-partlabel/disk-primary-internal /btrfs_tmp
      
      if [[ -e /btrfs_tmp/root ]]; then
        mkdir -p /btrfs_tmp/old_roots
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/root)" "+%Y-%m-%-d_%H:%M:%S")
        mv /btrfs_tmp/root "/btrfs_tmp/old_roots/$timestamp"
      fi


      if [[ -e /btrfs_tmp/home ]]; then
        mkdir -p /btrfs_tmp/old_homes
        timestamp=$(date --date="@$(stat -c %Y /btrfs_tmp/home)" "+%Y-%m-%-d_%H:%M:%S")
        mv /btrfs_tmp/home "/btrfs_tmp/old_homes/$timestamp"
      fi      

      delete_subvolume_recursively() {
          IFS=$'\n'
          for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
              delete_subvolume_recursively "/btrfs_tmp/$i"
          done
          btrfs subvolume delete "$1"
      }

      for i in $(find /btrfs_tmp/old_roots/ -maxdepth 1 -mtime +30); do
          delete_subvolume_recursively "$i"
      done

      for i in $(find /btrfs_tmp/old_homes/ -maxdepth 1 -mtime +30); do
          delete_subvolume_recursively "$i"
      done      

      btrfs subvolume create /btrfs_tmp/root
      
      btrfs subvolume create /btrfs_tmp/home
      chown root:root /btrfs_tmp/home
      chmod 755 /btrfs_tmp/home
      
      umount /btrfs_tmp
  '';

  environment.persistence."/persist" = {
    hideMounts = true;
    directories = [
      # "/var/log"
      "/var/lib/nixos"
    ];
    files = [
    ];
    # do not use home-manager's impermanence module as it comes with fuse performance penalty
    users.s = {
      directories = [
        "nixcfg"
      ];
    };
  };
}
