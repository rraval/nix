{ pkgs, config, ... }:
let
  user = config.box.user.login.name;
in
{
  services = {
    avahi = {
      enable = true;
      nssmdns4 = true;
      nssmdns6 = true;
    };

    printing = {
      enable = true;
      drivers = with pkgs; [
        gutenprint
        gutenprintBin
        hplip
        mfcl2720dwcupswrapper
        mfcl2720dwlpr
      ];
    };
  };

  users.users.${user}.extraGroups = [ "lp" ];
}
