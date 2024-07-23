{ pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    terminal = "${pkgs.wezterm}/bin/wezterm";
    theme = "glue_pro_blue";
    extraConfig = {
      modi = "drun,window,ssh";
    };
  };
}
