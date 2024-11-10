{ config, ... }:
let
  user = config.box.user.login.name;
in
{
  users.users.${user}.extraGroups = [ "audio" ];
}
