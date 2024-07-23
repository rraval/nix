{ config, ... }:
let
  user = config.box.user.login.name;
in
{
  console.useXkbConfig = true;

  services.xserver = {
    enable = true;
    displayManager.defaultSession = "xfce";
    desktopManager.xfce = {
      enable = true;
      noDesktop = true;
      enableXfwm = false;
    };
  };

  users.users.${user}.extraGroups = [ "video" ];
}
