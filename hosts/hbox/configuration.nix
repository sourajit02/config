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
  users.users.root.initialHashedPassword = "$y$j9T$LgZNfZgC.jlSpJHuYdWJW1$YcJSBxMF.9rWLb5ijXRKyoSJgfc6HWNdMlRkUxl1yND";
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

  users.mutableUsers = false;
  users.users.s = {
    home = "/home/s";
    isNormalUser = true;
    initialHashedPassword = "$y$j9T$LgZNfZgC.jlSpJHuYdWJW1$YcJSBxMF.9rWLb5ijXRKyoSJgfc6HWNdMlRkUxl1yND";
    shell = pkgs.nushell;
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
    ];
    createHome = true;
  };

  boot.initrd.systemd.enable = true;
  preservation = {
    enable = true;
    preserveAt."/persist" = {

      # commonMountOptions = [
      #   "noatime"
      #   "compress=zstd"
      # ];

      directories = [
        # "/tmp" # manage ram ballooning
        "/var/log"

        "/etc/secureboot"
        "/var/lib/bluetooth"
        "/var/lib/fprint"
        "/var/lib/fwupd"
        "/var/lib/libvirt"
        "/var/lib/power-profiles-daemon"
        "/var/lib/systemd/coredump"
        "/var/lib/systemd/rfkill"
        "/var/lib/systemd/timers"

        {
          directory = "/var/lib/nixos";
          inInitrd = true;
        }

      ];
      files = [
        "/var/lib/usbguard/rules.conf"
        {
          file = "/etc/machine-id";
          inInitrd = true;
          how = "symlink";
          configureParent = true;
        }

        {
          file = "/etc/ssh/ssh_host_rsa_key";
          how = "symlink";
          configureParent = true;
        }
        {
          file = "/etc/ssh/ssh_host_ed25519_key";
          how = "symlink";
          configureParent = true;
        }

      ];

      users.s = {
        commonMountOptions = [
          "x-gvfs-hide"
        ];
        directories = [
          # mounting issues, don't persist for now
          # https://github.com/nix-community/impermanence/pull/243
          # {
          # directory = ".local/share/";
          # mountOptions = [ "x-gvfs-trash" ];
          # how = "symlink";
          # mode = "0777";
          # configureParent = true;
          # parent.user = "s";
          # parent.group = "users";
          # parent.mode = "0777";
          # }
          "nixcfg"
          "downloads"
          ".local/state"
          ".config"
          {
            directory = ".ssh";
            mode = "0700";
          }
        ];
        files = [
          # ".config/nushell/history.sqlite3"
        ];
      };
    };

  };
  systemd.services.systemd-machine-id-commit = {
    unitConfig.ConditionPathIsMountPoint = [
      ""
      "/persistent/etc/machine-id"
    ];
    serviceConfig.ExecStart = [
      ""
      "systemd-machine-id-setup --commit --root /persistent"
    ];
  };

  # systemd.tmpfiles.rules = [
  #   "D /tmp 1777 root root 0" # Delete and recreate /tmp on boot
  # ];

}
