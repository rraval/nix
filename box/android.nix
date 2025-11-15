{ config, pkgs, ... }:
let
  user = config.box.user.login.name;
in
{
  users.users.${user}.extraGroups = [ "adbusers" ];
}
