{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-22.05.tar.gz";
  impermanence = builtins.fetchTarball "https://github.com/nix-community/impermanence/archive/master.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  # might not be needed
  programs.fuse.userAllowOther = true;

  # Home Manager config goes in here
  home-manager.users.s = {
    home.homeDirectory = "/home/<username>";
    imports = [ "${impermanence}/home-manager.nix" ];

    programs = {
      home-manager.enable = true;
      git = {
        # can use home-manager normally as well as with persistence
        enable = true;
        userName = "Example";
        userEmail = "Example@example.com";
      };
    };

    home.persistence."/nix/dotfiles" = {
      removePrefixDirectory = true; # for GNU Stow styled dotfile folders
      allowOther = true;
      directories = [
        "Atom/.atom/atom-discord"
        "Atom/.atom/packages"
        "Clementine/.config/Clementine"

        # fuse mounted from /nix/dotfiles/Firefox/.mozilla to /home/$USERNAME/.mozilla
        "Firefox/.mozilla"
      ];
      files = [
        "Atom/.atom/config.cson"
        "Atom/.atom/github.cson"
      ];
    };

    # fricking KDE Plasma has a bazillion files and each needs to be linked individually
    # because they're all just shoved into ~/.config and not into a single folder.
    # It's separate from the other dotfiles so I can write ".config"
    # instead of "Plasma/.config"
    home.persistence."/nix/dotfiles/Plasma" = {
      removePrefixDirectory = false;
      allowOther = true;
      directories = [
        ".config/gtk-3.0" # fuse mounted from /nix/dotfiles/Plasma/.config/gtk-3.0
        ".config/gtk-4.0" # to /home/$USERNAME/.config/gtk-3.0
        ".config/KDE"
        ".config/kde.org"
        ".config/plasma-workspace"
        ".config/xsettingsd"
        ".kde"

        ".local/share/baloo"
        ".local/share/dolphin"
        ".local/share/kactivitymanagerd"
        ".local/share/kate"
        ".local/share/klipper"
        ".local/share/konsole"
        ".local/share/kscreen"
        ".local/share/kwalletd"
        ".local/share/kxmlgui5"
        ".local/share/RecentDocuments"
        ".local/share/sddm"
      ];
      files = [
        ".config/akregatorrc"
        ".config/baloofileinformationrc"
        ".config/baloofilerc"
        ".config/bluedevilglobalrc"
        ".config/device_automounter_kcmrc"
        ".config/dolphinrc"
        ".config/filetypesrc"
        ".config/gtkrc"
        ".config/gtkrc-2.0"
        ".config/gwenviewrc"
        ".config/kactivitymanagerd-pluginsrc"
        ".config/kactivitymanagerd-statsrc"
        ".config/kactivitymanagerd-switcher"
        ".config/kactivitymanagerdrc"
        ".config/katemetainfos"
        ".config/katerc"
        ".config/kateschemarc"
        ".config/katevirc"
        ".config/kcmfonts"
        ".config/kcminputrc"
        ".config/kconf_updaterc"
        ".config/kded5rc"
        ".config/kdeglobals"
        ".config/kgammarc"
        ".config/kglobalshortcutsrc"
        ".config/khotkeysrc"
        ".config/kmixrc"
        ".config/konsolerc"
        ".config/kscreenlockerrc"
        ".config/ksmserverrc"
        ".config/ksplashrc"
        ".config/ktimezonedrc"
        ".config/kwinrc"
        ".config/kwinrulesrc"
        ".config/kxkbrc"
        ".config/mimeapps.list"
        ".config/partitionmanagerrc"
        ".config/plasma-localerc"
        ".config/plasma-nm"
        ".config/plasma-org.kde.plasma.desktop-appletsrc"
        ".config/plasmanotifyrc"
        ".config/plasmarc"
        ".config/plasmashellrc"
        ".config/PlasmaUserFeedback"
        ".config/plasmawindowed-appletsrc"
        ".config/plasmawindowedrc"
        ".config/powermanagementprofilesrc"
        ".config/spectaclerc"
        ".config/startkderc"
        ".config/systemsettingsrc"
        ".config/Trolltech.conf"
        ".config/user-dirs.dirs"
        ".config/user-dirs.locale"

        ".local/share/krunnerstaterc"
        ".local/share/user-places.xbel"
        ".local/share/user-places.xbel.bak"
        ".local/share/user-places.xbel.tbcache"
      ];
    };

    home.stateVersion = "21.11";
  };
}
