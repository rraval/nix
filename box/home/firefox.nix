{ config, pkgs, ... }:
{
  programs.firefox = {
    enable = true;
    nativeMessagingHosts = let
      pass = "${config.programs.password-store.package}/bin/pass";
      # Patching the source code is the official way to override the `pass`
      # binary used.
      #
      # See https://github.com/passff/passff-host?tab=readme-ov-file#preferences
      passff-host = pkgs.passff-host.overrideAttrs (old: {
        dontStrip = true;
        patchPhase = ''
          sed -i 's#COMMAND = "pass"#COMMAND = "${pass}"#' src/passff.py
        '';
      });
      passff-host-json-path = "lib/mozilla/native-messaging-hosts/passff.json";
    in [
      # The `passff-host` derivation has a symlink in `passff-host-json-path`,
      # which points to a real file somewhere in that derivation.
      #
      # However, home-manager naively copies just the symlink, which results in
      # an unresolvable `passff.json` being created.
      #
      # So create another derivation that copies the file contents of the
      # symlink, and let home-manager use that instead.
      (pkgs.concatTextFile {
        name = "passff-host-json";
        files = [ "${passff-host}/${passff-host-json-path}" ];
        destination = ["/${passff-host-json-path}"];
      })
    ];
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
