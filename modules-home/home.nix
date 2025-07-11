{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  home.packages = with pkgs; [
    trash-cli
  ];

  programs.nushell = {
    enable = true;
    extraConfig = ''
      def nrs [] {
            cd /home/s/
            git clone https://github.com/sourajit02/nixcfg or echo "nothing exists"
            cd nixcfg
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

  ## do not touch
  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
}
