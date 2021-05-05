{ name }: {
  enable = true;
  profiles."${name}" = {
    inherit name;
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
}
