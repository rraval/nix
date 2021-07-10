pkgs: with pkgs; [
  (callPackage (import ./git-nomad.nix) {})

  android-studio
  chromium
  dig
  discord
  fzf
  ghostwriter
  gimp
  imagemagick
  lens
  libreoffice
  nodejs
  obs-studio
  playerctl
  qrencode
  ripgrep
  rofimoji
  skypeforlinux
  slack
  spotify
  transmission-gtk
  vlc
  xclip
  yubikey-manager
  zbar
  zoom-us
]
