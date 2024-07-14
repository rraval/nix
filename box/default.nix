{ pkgs, lib, config, ... }:
let
  cfg = config.box;
  user = cfg.user.login.name;
in {
  options = with lib; {
    box = {
      user = {
        login = {
          name = mkOption {
            type = types.str;
            description = ''
              User ID to login as.
            '';
          };

          hashedPassword = mkOption {
            type = types.str;
            description = ''
              Password hash generated by `mkpasswd -m sha-256`.
            '';
          };
        };

        realName = mkOption {
          type = types.str;
          description = ''
            Name for the person representing this user.
          '';
        };

        email = mkOption {
          type = types.str;
          description = ''
            Email for the person representing this user.
          '';
        };
      };

      disks = mkOption {
        description = ''
          LUKS encrypted disks that should be decrypted at boot time.

          Each <name> will be opened as `/dev/mapper/<name>`, which can then be
          used as a LVM physical volume.
        '';

        type = types.attrsOf (types.submodule {
          options = {
            encryptedDevice = mkOption {
              type = types.str;
              description = "Path to the encrypted block device";
            };

            isSolidState = mkOption {
              type = types.bool;
              description = "Allow TRIM requests to the underlying device";
            };
          };
        });

        example = {
          decrypted0 = {
            encryptedDevice =
              "/dev/disk/by-uuid/00000000-0000-0000-0000-000000000000";
            isSolidState = true;
          };
        };
      };
    };
  };

  imports = [
    ./android.nix
    ./audio.nix
    ./bluetooth.nix
    ./boot.nix
    ./docker.nix
    ./environment.nix
    ./filesystems.nix
    ./gaming.nix
    ./graphical.nix
    ./home
    ./networking.nix
    ./nix.nix
    ./printer.nix
    ./scanner.nix
    ./users.nix
    ./yubikey.nix
  ];

  config = {
    system.stateVersion = "20.09";

    nixpkgs.config.allowUnfree = true;
    hardware.enableRedistributableFirmware = true;

    powerManagement.cpuFreqGovernor = "ondemand";
  };
}
