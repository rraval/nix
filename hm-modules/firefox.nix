{ config, ... }: {
  programs.firefox = {
    enable = true;
    profiles."${config.home.username}" = {
      name = config.home.username;
      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "signon.rememberSignons" = false;
      };
      userChrome = ''
        #TabsToolbar {
          visibility: collapse;
        }

        #sidebar-box[sidebarcommand^="treestyletab"] > #sidebar-header {
          visibility: collapse;
        }
      '';
    };
  };
}
