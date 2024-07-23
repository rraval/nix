{ config, ... }:
let
  user = config.box.user.login.name;
in
{
  hardware.pulseaudio = {
    enable = true;
    daemon.config = {
      flat-volumes = "no";
      realtime-scheduling = "yes";
      rlimit-rttime = -1;
      exit-idle-time = -1;
    };
  };

  users.users.${user}.extraGroups = [ "audio" ];

  programs.noisetorch.enable = true;
}
