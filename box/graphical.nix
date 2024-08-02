{ config, ... }:
let
  user = config.box.user.login.name;
in
{
  console.useXkbConfig = true;

  services.displayManager = {
    enable = true;
    defaultSession = "xfce";
  };

  services.xserver = {
    enable = true;
    desktopManager.xfce = {
      enable = true;
      noDesktop = true;
      enableXfwm = false;
    };
  };

  users.users.${user}.extraGroups = [ "video" ];
}
