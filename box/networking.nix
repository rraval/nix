{ config, ... }: let
  user = config.box.user.login.name;
in {
  networking = {
    # global useDHCP is deprecated, don't use it
    useDHCP = false;

    networkmanager.enable = true;

    firewall.allowedTCPPorts = [
      # for VLC Chromecast integration, see
      # https://github.com/NixOS/nixpkgs/blob/c207be6/pkgs/applications/video/vlc/default.nix#L20
      8010

      # HTTP servers for local development
      8888
    ];
    firewall.allowedUDPPortRanges = [ { from = 32768; to = 60999; } ];
  };

  users.users.${user}.extraGroups = [ "networkmanager" ];
}
