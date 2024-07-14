{ pkgs, ... }: {
  xsession = {
    enable = true;

    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
      extraPackages = haskellPkgs: with haskellPkgs; [ dbus ];
      config = ./xmonad.hs;
    };

    initExtra = ''
      # Disable session saving on exit
      ${pkgs.xfce.xfconf}/bin/xfconf-query -c xfce4-session -p /general/SaveOnExit -s false

      # xfsettingsd messes with xmonad workspace names for whatever reason
      ${pkgs.xfce.xfconf}/bin/xfconf-query -c xfwm4 -p /general/workspace_names -s 1 -s 2 -s 3 -s 4 -s 5 -s 6 -s 7 -s 8 -s 9

      # Power manager
      xfce_power_manager() {
        ${pkgs.xfce.xfconf}/bin/xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/"$1" -s "$2"
      }
      xfce_power_manager show-tray-icon true
      xfce_power_manager handle-brightness-keys true
      xfce_power_manager lid-action-on-battery 1

      ${pkgs.runtimeShell} ${pkgs.xfce.xfce4-session.xinitrc} &
    '';
  };
}
