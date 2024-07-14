{ config, pkgs, ... }: {
  nix = {
    settings.allowed-users = [ config.box.user.login.name ];
    package = pkgs.nixUnstable;
    extraOptions = ''
      experimental-features = nix-command flakes
      !include /etc/nix/extra-nix.conf
    '';
  };
}
