{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    inputs.niri.homeModules.niri
  ];

  home.packages = with pkgs; [
    # niri
    waybar
    fuzzel
    mako
    trash-cli
    qutebrowser
  ];

  programs.waybar.settings.mainBar.layer = "top";
  programs.waybar.systemd.enable = true;

  home.sessionVariables = {
    XKB_DEFAULT_LAYOUT = "us";
    XKB_DEFAULT_VARIANT = "colemak";
  };

  programs.qutebrowser = {
    enable = true;
  };

  programs.nushell = {
    enable = true;
    extraConfig = ''
      def nrs [] {
            cd /home/s/nixcfg
            git pull
            # rm -rf nixcfg
            # git clone https://github.com/sourajit02/nixcfg
            # cd nixcfg
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
  programs.alacritty = {
    enable = true;
  };

  programs.helix = {
    enable = true;
    settings = {
      theme = "autumn_night_transparent";
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

  # modules = [
  #   niri.homeModules.config
  #   {
  #     programs.niri.settings = {
  #       outputs."eDP-1".scale = 2.0;
  #     };
  #   }
  # ];

  programs.niri = {
    enable = true;
    # settings = {
    #   environment."NIXOS_OZONE_WL" = "1";
    #   input = {
    #     keyboard = {
    #       xkb = {
    #         layout = "us";
    #         variant = "colemak";
    #         options = "compose:ralt,ctrl:nocaps";
    #       };
    #     };
    #   };
    # };

    # settings = ''
    #   input {
    #     keyboard {
    #       xkb {
    #         layout "us"
    #         variant "colemak"
    #         // options "compose:ralt,ctrl:nocaps"
    #       }
    #     }
    #   }

    #   // Add other niri configuration here
    #   layout {
    #     gaps 2
    #     center-focused-column "never"
    #   }

    #   spawn-at-startup "waybar"
    # '';

  };

  ## do not touch
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
}
