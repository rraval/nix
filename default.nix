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
{ pkgs, lib, config, ... }: let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    optional
    types
  ;
  util = import ./util.nix;
  hmLib = pkgs.callPackage <home-manager/modules/lib> {};
  cfg = config.rravalBox;
  hmCfg = config.home-manager.users.${cfg.user.name};
  homeDir = hmCfg.home.homeDirectory;
  encircleRepoDir = "${homeDir}/encircle";
in {
  options.rravalBox = {
    enable = mkEnableOption "Configure this machine for rraval";

    system = {
      locale = mkOption {
        default = "en_CA.UTF-8";
        description = "System locale";
        type = types.str;
      };

      timeZone = mkOption {
        default = "America/Toronto";
        description = "System timezone";
        type = types.str;
      };
    };

    user = {
      name = mkOption {
        description = "Username in the single-user system";
        type = types.str;
      };

      sha256Password = mkOption {
        description = "SHA 256 hash of user in single-user system. Use `mkpasswd -m sha-512` to generate";
        type = types.str;
      };

      realName = mkOption {
        description = "Full name to use in Git commits etc.";
        type = types.str;
      };

      email = mkOption {
        description = "Email to use in Git commits etc.";
        type = types.str;
      };
    };

    networking = {
      hostName = mkOption {
        description = "Networking hostname of this machine";
        type = types.str;
      };

      wiredEthernet = mkOption {
        description = "Optional single network interface to bring up with DHCP";
        type = types.nullOr types.str;
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
        allowedUsers = [ cfg.user.name ];
        package = pkgs.nixUnstable;
        extraOptions = "experimental-features = nix-command flakes";
      };
      nixpkgs.config.allowUnfree = true;
      time.timeZone = cfg.system.timeZone;
      system.stateVersion = "20.09";

      networking = mkMerge [
        {
          # global useDHCP is deprecated, don't use it
          useDHCP = false;

          hostName = cfg.networking.hostName;
        }

        (mkIf (cfg.networking.wiredEthernet != null) {
          interfaces.${cfg.networking.wiredEthernet}.useDHCP = true;
        })
      ];

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

      i18n.defaultLocale = cfg.system.locale;
      console.useXkbConfig = true;
      hardware = mkMerge [
        {
          pulseaudio.enable = true;
        }

        (mkIf cfg.bluetooth {
          bluetooth.enable = true;
        })
      ];

      users = {
        mutableUsers = false;

        groups.${cfg.user.name} = {
          gid = 1000;
        };

        users.${cfg.user.name} = {
          isNormalUser = true;
          uid = 1000;
          group = cfg.user.name;
          extraGroups = [ "wheel" "audio" ];
          hashedPassword = cfg.user.sha256Password;
          createHome = true;
          home = "/home/${cfg.user.name}";
          shell = pkgs.fish;
        };
      };

      services = let
        encircleVpn = cfg.toil.encircle.vpn;
      in mkMerge [
        {
          dnsmasq = {
            enable = true;
            extraConfig = ''
              ${lib.optionalString (encircleVpn != null) ''
                server=/encirclestaging.com/${encircleVpn.dnsIp}
                server=/encircleproduction.com/${encircleVpn.dnsIp}
              ''}
            '';
          };

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

          xserver = {
            enable = true;
            xkbOptions = "ctrl:nocaps";
            displayManager.defaultSession = "xfce";
            desktopManager.xfce = {
              enable = true;
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

        variables = {
          EDITOR = "nvim";
          VISUAL = "nvim";
        };
      };

      home-manager = {
        useUserPackages = true;
        useGlobalPkgs = true;

        users.${cfg.user.name} = {
          home.packages = import ./home-packages.nix pkgs;

          programs = {
            direnv = {
              enable = true;
              enableNixDirenvIntegration = true;
            };

            firefox = import ./firefox.nix { name = cfg.user.name; };

            fish = import ./fish.nix;

            git = import ./git.nix {
              name = cfg.user.realName;
              email = cfg.user.email;
            };

            gpg.enable = true;

            neovim = import ./neovim.nix pkgs;

            password-store = {
              enable = true;
              package = pkgs.pass.withExtensions (exts: [ exts.pass-otp ]);
            };

            ssh = {
              enable = true;
              userKnownHostsFile = "${homeDir}/.ssh/known_hosts ${./known_hosts}";
            };
          };

          services = {
            dropbox = {
              enable = true;
              path = "${homeDir}/dropbox";
            };

            gpg-agent = {
              enable = true;
              pinentryFlavor = "gtk2";
            };
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

            configFile = {
              "alacritty.yml".source = ./alacritty.yml;
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

            # Enabling `windowManager.xmonad` above replaces
            # `windowManager.command` to launch xmonad directly.
            #
            # Instead, we want to launch `xfce4-session`, which will properly
            # launch the desktop environment, but we want to keep using the
            # home-manager xmonad package since it exposes nice configuration
            # options and sets up auto recompilation on file change.
            #
            # Start by using `mkForce` to override the command to launch
            # `xfce4-session` directly.
            windowManager.command = pkgs.lib.mkForce "${pkgs.runtimeShell} ${pkgs.xfce.xfce4-session.xinitrc}";
          };

          home.file = {
            # We launch `xfce4-session` as the `windowManager.command`, so
            # let's make it launch xmonad.
            #
            # This requires some gymnastics to extract the correct xmonad
            # package from the home-manager configuration.
            ".config/autostart/xmonad.desktop".text = let
              xmonad = util.findPackage hmCfg.home.packages "xmonad-with-packages";
            in ''
              [Desktop Entry]
              Type=Application
              Name=xmonad
              Exec=${xmonad}/bin/xmonad
            '';

            ".config/autostart/DisableXfceSessionSaveOnExit.desktop".text = ''
              [Desktop Entry]
              Type=Application
              Name=Disable XFCE Session Save on Exit
              Exec=${pkgs.xfce.xfconf}/bin/xfconf-query -c xfce4-session -p /general/SaveOnExit -s false
            '';
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

          systemd.user = let
            mkGitCloneOneshot = import ./git-clone.nix pkgs;
          in {
            startServices = "sd-switch";
            services = mkMerge [
              (mkIf cfg.toil.sshKeyTrustedByGitHub {
                clone-rraval-pass = mkGitCloneOneshot {
                  url = "git@github.com:rraval/pass.git";
                  dest = hmCfg.programs.password-store.settings.PASSWORD_STORE_DIR;
                };
              })

              (mkIf cfg.toil.encircle.sshKeyTrustedByPhabricator {
                clone-rraval-encircle = mkGitCloneOneshot {
                  url = "ssh://phabricator-vcs@phabricator.internal.encircleapp.com:2222/diffusion/2/encircle.git";
                  dest = encircleRepoDir;
                };
              })
            ];
          };
        };
      };
    }

    (mkIf cfg.rootDevice.isSolidState {
      fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];
    })
  ]);
}
