{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    inputs.niri.homeModules.niri # nixpkgs version has no home-manager intergration, so use flake
    # inputs.stylix.nixosModules.stylix
  ];

  home.packages = with pkgs; [
    waybar
    fuzzel
    # rofi
    ghostty
    mako
    trash-cli
    qutebrowser
    xwayland-satellite
    krita
    swaybg
    blender
  ];

  home.sessionVariables = {
    XKB_DEFAULT_LAYOUT = "us";
    XKB_DEFAULT_VARIANT = "colemak";
    QT_QPA_PLATFORM = "wayland;xcb";
  };

  programs.qutebrowser = {
    enable = true;
  };
  programs.fuzzel = {
    enable = true;
  };
  programs.waybar = {
    enable = true;
  };

  programs.nushell = {
    enable = true;
    extraConfig = ''
      def nrs [] {
            cd /home/s/config
            git pull
            # rm -rf config
            # git clone https://github.com/sourajit02/config
            # cd config
            sudo nixos-rebuild switch --flake
            reboot
          }
    '';
    settings = {
      show_banner = false;
      completions.external = {
        enable = true;
        max_results = 200;
      };
      history.max_size = 1000000;
      history.sync_on_enter = true;
      history.file_format = "sqlite";
      history.isolation = false;
    };
  };

  programs.yazi = {
    enable = true;
  };
  programs.ghostty = {
    enable = true;
  };

  programs.helix = {
    enable = true;
    settings = {
      # theme = "autumn_night_transparent"; # stylix will take care of this
      editor.cursor-shape = {
        normal = "block";
        insert = "bar";
        select = "underline";
      };
    };
    languages.language = [
      {
        name = "nix";
        auto-format = true;
        formatter.command = lib.getExe pkgs.nixfmt-rfc-style;
      }
    ];
    themes = {
      autumn_night_transparent = {
        "inherits" = "autumn_night";
        "ui.background" = { };
      };
    };
  };

  # programs.krita.enable = true;
  # wayland compositor settings
  programs.waybar.settings.mainBar.layer = "top";
  programs.waybar.systemd.enable = true;
  programs.niri = {
    enable = true;
    settings = {
      spawn-at-startup = [
        { command = [ "waybar" ]; }
        {
          command = [
            "swaybg"
            "--image"
            "${config.stylix.image}"
          ];
        }
        # { command = [ "~/.config/niri/scripts/startup.sh" ]; }
      ];
      prefer-no-csd = true;
      environment."NIXOS_OZONE_WL" = "1";
      layout = {
        gaps = 4;
        border.width = 4;
      };
      input = {
        keyboard = {
          xkb = {
            layout = "us";
            variant = "colemak";
            options = "compose:ralt,ctrl:nocaps";
          };
        };
      };

      binds = with config.lib.niri.actions; {
        "Mod+Return".action = spawn "ghostty";
        "Mod+N".action = spawn "ghostty -e yazi";
        "Mod+slash".action = show-hotkey-overlay;
        "Mod+D".action = spawn "fuzzel";
        # "Mod+D".action = spawn "rofi";
      };
    };
  };

  ## do not touch
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
}
