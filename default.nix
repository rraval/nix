# The canonical NixOS machine for rraval.
#
# Setup to use UEFI with a single LUKS encrypted disk with LVM on the inside.
#
# TODO: Turn on sysrq
#
# TODO: Turn this into a nix flake.
#
# TODO: Put home-manager dependency in this file.
#
# TODO: Integrate all other dotfiles.
#
# TODO: The git clone thing doesn't work and is nonsense. Replace it with a
# bespoke git manager tool.
{ pkgs, lib, config, ... }: let
  user = {
    name = "rraval";
    realName = "Ronuk Raval";
    email = "ronuk.raval@gmail.com";
  };
  locale = "en_CA.UTF-8";
  timeZone = "America/Toronto";

  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
  ;
  hmLib = pkgs.callPackage <home-manager/modules/lib> {};
  cfg = config.rravalBox;
  hmCfg = config.home-manager.users.${user.name};
  homeDir = hmCfg.home.homeDirectory;
  encircleRepoDir = "${homeDir}/encircle";
in {
  options.rravalBox = {
    enable = mkEnableOption "Configure this machine for rraval";

    networking = {
      hostName = mkOption {
        description = "Networking hostname of this machine";
        type = types.str;
      };
    };

    rootDevice = {
      encryptedDisk = mkOption {
        description = ''
          Single block device to mount as root.

          This box configuration assumes a single large partition, encrypted
          with LUKS, with LVM on the inside.
        '';
        type = types.path;
      };

      isSolidState = mkOption {
        description = "Is the block device backed by a solid state drive?";
        type = types.bool;
      };
    };

    toil = {
      sshKeyTrustedByGitHub = mkEnableOption "cloning private repos from GitHub";

      encircle = {
        sshKeyTrustedByPhabricator = mkEnableOption "cloning repos from Phabricator";

        postgresql = mkEnableOption "setup Postgres with encircle user and DB extensions";

        vpn = mkOption {
          description = "OpenVPN configuration to connect to Encircle intranet";
          default = null;
          type = with types; nullOr (submodule {
            options = {
              config = mkOption {
                description = "Path to OpenVPN config file including inline certificates";
                type = str;
              };

              # We could extract this from the DHCP options OpenVPN pushes down
              # on connect, but that would require writing even more custom
              # code to hook it up to dnsmasq
              dnsIp = mkOption {
                description = "IP address for DNS lookups on intranet domains";
                type = str;
              };
            };
          });
        };
      };
    };
  };

  config = mkIf cfg.enable (import ./box {
    inherit pkgs lib hmLib user locale timeZone cfg hmCfg homeDir encircleRepoDir;
  });
}
