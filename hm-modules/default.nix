{ pkgs, lib, ...}: {
  imports = [
    ./direnv.nix
    ./firefox.nix
    ./fish.nix
    ./git.nix
    ./gpg.nix
    ./neovim
    ./obs-studio.nix
    ./password-store.nix
    ./polybar.nix
    ./rofi.nix
    ./ssh
    ./visidata.nix
    ./wezterm.nix
    ./xdg.nix
    ./xsession
  ];

  options = with lib; {
    my = {
      realName = mkOption {
        type = types.str;
        description = ''
          Name for the person representing this user.
        '';
      };

      email = mkOption {
        type = types.str;
        description = ''
          Email for the person representing this user.
        '';
      };
    };
  };

  config.home = {
    stateVersion = "20.09";
    keyboard = {
      options = ["ctrl:nocaps"];
    };

    packages = with pkgs; [
      android-studio
      audacity
      blender
      bruno
      calibre
      chromium
      corefonts
      cura
      darktable
      delta
      dig
      discord
      diskonaut
      flameshot
      fx
      fzf
      gh
      ghostwriter
      gimp
      git-nomad
      gnome.simple-scan
      hexyl
      htop
      imagemagick
      inkscape
      iotop
      kdenlive
      lens
      libation
      libfaketime
      libreoffice
      musescore
      nodejs
      obsidian
      okular
      pdftk
      pgformatter
      playerctl
      posterazor
      pv
      qrencode
      rehex
      ripgrep
      rofimoji
      rpi-imager
      screenkey
      # broken with compile error in sfnt.cpp
      # scribusUnstable
      skypeforlinux
      slack
      spotify
      stremio
      subsurface
      tig
      tmux
      transmission-gtk
      trippy
      unzip
      vistafonts
      vlc
      wireshark
      xclip
      youtube-dl
      yubikey-manager
      zbar
      zoom-us
    ];
  };
}
