{ config, pkgs, ... }:
let
  user = config.box.user.login.name;
in
{
  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = true;

    users.${user} = {
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

      home = {
        stateVersion = "20.09";
        keyboard = {
          options = [ "ctrl:nocaps" ];
        };

        packages = with pkgs; [
          audacity
          bruno
          calibre
          (chromium.override { enableWideVine = true; })
          corefonts
          darktable
          dig
          discord
          flameshot
          fx
          fzf
          gh
          gh-markdown-preview
          gimp
          git-nomad
          hexyl
          htop
          imagemagick
          inkscape
          iotop
          jaq
          jnv
          kdePackages.kdenlive
          lens
          libation
          libfaketime
          libreoffice
          musescore
          nix-inspect
          nodejs
          obsidian
          kdePackages.okular
          pdftk
          pgformatter
          playerctl
          pv
          qrencode
          rehex
          ripgrep
          rofimoji
          rpi-imager
          screenkey
          simple-scan
          skypeforlinux
          slack
          spotify
          stremio
          subsurface
          tig
          tmux
          transmission_4-gtk
          trippy
          unzip
          vistafonts
          vlc
          wireshark
          xclip
          yubikey-manager
          zbar
          zeal
          zoom-us
        ];
      };
    };
  };
}
