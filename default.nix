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
    mkMerge
    mkOption
    optional
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

    bluetooth = mkEnableOption "bluetooth support";

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

  config = mkIf cfg.enable (mkMerge [
    {
      nix = {
        allowedUsers = [ user.name ];
        package = pkgs.nixUnstable;
        extraOptions = "experimental-features = nix-command flakes";
      };
      nixpkgs.config.allowUnfree = true;
      time.timeZone = timeZone;
      system.stateVersion = "20.09";

      networking = mkMerge [
        {
          # global useDHCP is deprecated, don't use it
          useDHCP = false;

          hostName = cfg.networking.hostName;

          networkmanager.enable = true;

          # for VLC Chromecast integration, see
          # https://github.com/NixOS/nixpkgs/blob/c207be6/pkgs/applications/video/vlc/default.nix#L20
          firewall.allowedTCPPorts = [ 8010 ];
          firewall.allowedUDPPortRanges = [ { from = 32768; to = 60999; } ];
        }
      ];

      powerManagement.cpuFreqGovernor = "ondemand";

      boot = {
        loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };
        initrd.luks.devices = {
          decrypted0 = {
            device = builtins.toString cfg.rootDevice.encryptedDisk;
            preLVM = true;
            allowDiscards = cfg.rootDevice.isSolidState;
          };
        };
      };

      i18n.defaultLocale = locale;
      console.useXkbConfig = true;
      hardware = mkMerge [
        {
          pulseaudio.enable = true;
          sane = {
            enable = true;
            extraBackends = [ pkgs.hplipWithPlugin ];
          };
        }

        (mkIf cfg.bluetooth {
          bluetooth.enable = true;
        })
      ];

      users = {
        mutableUsers = false;

        groups.${user.name} = {
          gid = 1000;
        };

        users.${user.name} = {
          isNormalUser = true;
          uid = 1000;
          group = user.name;
          extraGroups = [ "wheel" "audio" "video" "networkmanager" "docker" "adbusers" "scanner" "lp" ];
          hashedPassword = lib.removeSuffix "\n" (builtins.readFile (./passwd. + user.name));
          createHome = true;
          home = "/home/${user.name}";
          shell = pkgs.fish;
        };
      };

      virtualisation.docker.enable = true;

      services = let
        encircleVpn = cfg.toil.encircle.vpn;
      in mkMerge [
        {
          avahi.enable = true;

          dnsmasq = {
            enable = true;
            extraConfig = ''
              ${lib.optionalString (encircleVpn != null) ''
                server=/encirclestaging.com/${encircleVpn.dnsIp}
                server=/encircleproduction.com/${encircleVpn.dnsIp}
              ''}
            '';
          };

          pcscd.enable = true;

          postgresql = let
            postgresqlPkg = pkgs.postgresql_13;
            hasEncircle = cfg.toil.encircle.postgresql;
          in mkMerge [
            {
              enable = true;
              package = postgresqlPkg;
              initdbArgs = [ "--locale" "C" "-E" "UTF8" ];
              settings = {
                TimeZone = "UTC";
              };
              authentication = "local all all trust";
              ensureUsers = optional hasEncircle {
                name = "encircle";
                # FIXME: no way to grant CREATEDB
                # https://github.com/NixOS/nixpkgs/blob/39e6bf76474ce742eb027a88c4da6331f0a1526f/nixos/modules/services/databases/postgresql.nix#L381
              };
            }

            (mkIf hasEncircle {
              extraPlugins = import (/. + "${encircleRepoDir}/db_extensions") {
                stdenv = pkgs.stdenv;
                postgresql = postgresqlPkg;
              };
            })
          ];

          printing = {
            enable = true;
            drivers = with pkgs; [
              gutenprint
              gutenprintBin
              hplip
              mfcl2720dwcupswrapper
              mfcl2720dwlpr
            ];
          };

          udev.packages = [ pkgs.android-udev-rules ];

          xserver = {
            enable = true;
            displayManager.defaultSession = "xfce";
            desktopManager.xfce = {
              enable = true;
              noDesktop = true;
              enableXfwm = false;
            };
          };
        }

        (mkIf cfg.bluetooth {
          blueman.enable = true;
        })

        (mkIf (encircleVpn != null) {
          openvpn.servers.encircle = {
            config = "config ${encircleVpn.config}";
          };
        })
      ];

      environment = {
        systemPackages = import ./system-packages.nix pkgs;

        shells = [
          pkgs.fish
        ];

        variables = {
          EDITOR = "nvim";
          VISUAL = "nvim";
        };
      };

      home-manager = {
        useUserPackages = true;
        useGlobalPkgs = true;

        users.${user.name} = {
          home = {
            packages = import ./home-packages.nix pkgs;
            keyboard = {
              options = ["ctrl:nocaps"];
            };
          };

          programs = {
            direnv = {
              enable = true;
              nix-direnv = {
                enable = true;
                enableFlakes = true;
              };
            };

            firefox = import ./firefox.nix { name = user.name; };

            fish = import ./fish.nix pkgs;

            git = import ./git.nix {
              name = user.realName;
              email = user.email;
            };

            gpg = {
              enable = true;

              settings = {
                keyserver = "hkps://keys.openpgp.org";
              };

              # Use PC/SC to talk to smartcards
              # https://ludovicrousseau.blogspot.com/2019/06/gnupg-and-pcsc-conflicts.html
              scdaemonSettings.disable-ccid = true;
            };

            neovim = import ./neovim.nix pkgs;

            password-store = {
              enable = true;
              package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
              settings = {
                PASSWORD_STORE_DIR = "${homeDir}/pass";
              };
            };

            rofi = {
              enable = true;
              terminal = "${pkgs.xfce.terminal}/bin/xfce4-terminal";
              theme = "glue_pro_blue";
              extraConfig = {
                modi = "drun,window,ssh";
              };
            };

            ssh = {
              enable = true;
              userKnownHostsFile = "${homeDir}/.ssh/known_hosts ${./known_hosts}";
              serverAliveInterval = 60;
            };
          };

          services = {
            dropbox = {
              enable = true;
              path = "${homeDir}/dropbox";
            };

            gpg-agent = let hour_in_seconds = 60 * 60; in {
              enable = true;
              pinentryFlavor = "gtk2";
              enableSshSupport = true;
              defaultCacheTtl = hour_in_seconds;
              maxCacheTtl = 2 * hour_in_seconds;
              defaultCacheTtlSsh = 4 * hour_in_seconds;
              maxCacheTtlSsh = 12 * hour_in_seconds;
              extraConfig = ''
                auto-expand-secmem 0x30000
              '';
            };

            polybar = import ./polybar.nix pkgs;
          };

          xdg = {
            userDirs = {
              enable = true;
              desktop = "$HOME";
              documents = "$HOME";
              download = "$HOME/download";
              music = "$HOME";
              pictures = "$HOME";
              publicShare = "$HOME";
              templates = "$HOME";
              videos = "$HOME";
            };
          };

          xsession = {
            enable = true;

            windowManager.xmonad = {
              enable = true;
              enableContribAndExtras = true;
              extraPackages = haskellPkgs: with haskellPkgs; [
                dbus
              ];
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

          home.file = {
            ".config/nvim/coc-settings.json".source = ./coc-settings.json;
            ".config/xfce4/terminal/terminalrc".source = ./terminalrc;
            ".mozilla/native-messaging-hosts/passff.json".source = "${pkgs.passff-host}/share/passff-host/passff.json";
          };

          home.activation = {
            sshKeygen = hmLib.dag.entryAfter ["writeBoundary"] ''
              if [[ ! -f "$HOME"/.ssh/id_rsa ]]; then
                $DRY_RUN_CMD ssh-keygen -b 4096 -f "$HOME"/.ssh/id_rsa -N ""
              fi
            '';

            # From https://logs.nix.samueldr.com/home-manager/2020-11-12
            #
            # 08:17 <coco> For gpg, I get "gpg: WARNING: unsafe permissions on
            # homedir '/home/<user>/.gnupg'". I can perform a `chmod go-rwx`
            # to fix this, but is there a declarative way to do that?
            #
            # 11:22 <hexa-> chmod 700 ~/.gnupg
            #
            # 11:22 <hexa-> and be done
            #
            # 11:28 <piegames1> coco: As the folder itself is not really part
            # of any declarativeness, you only need to run the command once
            # and be done.
            gpgPermissions = hmLib.dag.entryAfter ["writeBoundary"] ''
              $DRY_RUN_CMD chmod 700 ${hmCfg.programs.gpg.homedir}
            '';
          };
        };
      };
    }

    (mkIf cfg.rootDevice.isSolidState {
      fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];
    })
  ]);
}
