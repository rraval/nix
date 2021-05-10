pkgs: {
  enable = true;
  package = pkgs.polybarFull;
  script = "polybar rail &";
  settings = {
    "bar/rail" = {
      font = [
        "DejaVu Sans:style=Book;2"
        "Noto Emoji:style=Regular:scale=10;2"
      ];
      tray = {
        position = "right";
      };
      modules = {
        left = "workspaces";
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
    "module/workspaces" = {
      type = "internal/xworkspaces";
    };
  };
}
