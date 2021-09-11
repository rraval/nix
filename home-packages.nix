pkgs: with pkgs; [
  (callPackage (import ./git-nomad.nix) {})

  android-studio
  audacity
  chromium
  dig
  discord
  fzf
  ghostwriter
  gimp
  imagemagick
  inkscape
  kdenlive
  lens
  libreoffice
  nodejs
  obs-studio
  okular
  playerctl
  pv
  qrencode
  ripgrep
  rofimoji
  scribusUnstable
  skypeforlinux
  slack
  spotify
  transmission-gtk
  vlc
  xclip
  youtube-dl
  yubikey-manager
  zbar
  zoom-us
]
