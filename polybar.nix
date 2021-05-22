pkgs: {
  enable = true;
  package = pkgs.polybarFull;
  script = "polybar rail &";
  settings = {
    "bar/rail" = {
      background = "#ffffff";
      foreground = "#000000";
      font = [
        "DejaVu Sans:style=Book;2"
        "Noto Emoji:style=Regular:scale=10;2"
        "Liberation Mono:style=Regular;2"
      ];
      tray = {
        position = "right";
      };
      modules = {
        left = "workspaces window";
        right = "date volume";
      };
      module.margin = {
        left = 1;
        right = 1;
      };
    };
    "module/date" = {
      type = "internal/date";
      date = "%b %d";
      time = "%H:%M";
      label = "%time% %date%";
    };
    "module/volume" = {
      type = "internal/pulseaudio";
      label = {
        volume = "🔉";
        muted = "🔇";
      };
      click.right = "pavucontrol";
    };
    "module/window" = {
      type = "internal/xwindow";
      label-maxlen = 160;
      label-empty = "";
    };
    "module/workspaces" = {
      type = "internal/xworkspaces";
      label = {
        active = "[%name%]";
        active-font = 3;
        occupied = "%name%";
        occupied-font = 3;
        urgent = "{%name%}";
        urgent-font = 3;
        empty = "";
      };
    };
  };
}
