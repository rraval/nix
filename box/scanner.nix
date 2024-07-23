{ pkgs, config, ... }:
let
  user = config.box.user.login.name;
in
{
  hardware.sane = {
    enable = true;
    extraBackends = [ pkgs.sane-airscan ];
  };

  users.users.${user}.extraGroups = [ "scanner" ];
}
