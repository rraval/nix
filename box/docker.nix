{ config, ... }:
let user = config.box.user.login.name;
in {
  virtualisation.docker.enable = true;

  users.users.${user}.extraGroups = [ "docker" ];
}
