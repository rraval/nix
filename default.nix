# The canonical NixOS machine for rraval.
#
# Setup to use UEFI with a single LUKS encrypted disk with LVM on the inside.
#
# TODO: Turn this into a nix flake.
#
# TODO: Put home-manager dependency in this file.
#
# TODO: XFCE stop session autosave. Fully manage session configuration. XFCE start xmonad.
#
# TODO: Integrate all other dotfiles.
{ pkgs, lib, config, ... }: let
  inherit (lib)
    mkOption
    mkEnableOption
    mkIf
    mkMerge
    types
  ;
  util = import ./util.nix;
  cfg = config.rravalBox;
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
  };

  config = mkIf cfg.enable (mkMerge [
    {
      nixpkgs.config.allowUnfree = true;
      time.timeZone = cfg.system.timeZone;
      system.stateVersion = "20.09";
      nix.allowedUsers = [ cfg.user.name ];

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

      users = {
        mutableUsers = false;

        groups.${cfg.user.name} = {
          gid = 1000;
        };

        users.${cfg.user.name} = {
          isNormalUser = true;
          uid = 1000;
          group = cfg.user.name;
          extraGroups = [ "wheel" ];
          hashedPassword = cfg.user.sha256Password;
          createHome = true;
          home = "/home/${cfg.user.name}";
          shell = pkgs.fish;
        };
      };

      services.xserver = {
        enable = true;
        xkbOptions = "ctrl:nocaps";
        displayManager.defaultSession = "xfce";
        desktopManager.xfce = {
          enable = true;
          enableXfwm = false;
        };
      };

      environment = {
        systemPackages = with pkgs; [
          fish
          git
          neovim
        ];

        variables = {
          EDITOR = "nvim";
          VISUAL = "nvim";
        };
      };

      home-manager = {
        useUserPackages = true;
        useGlobalPkgs = true;

        users.${cfg.user.name} = {
          programs = {
            firefox = {
              enable = true;
            };

            fish = {
              enable = true;
            };

            git = {
              enable = true;
              userName = cfg.user.realName;
              userEmail = cfg.user.email;
            };

            neovim = {
              enable = true;
              extraConfig = ''
                " mandatory to get plugins to generate
              '';
              plugins = with pkgs.vimPlugins; [
                vim-nix
              ];
            };
          };

          xsession = let userCfg = config.home-manager.users.${cfg.user.name}; in {
            enable = true;

            # There's some spooky action at a distance here.
            #
            # The login manager is going to launch the script at `~/.xsession`.
            #
            # We want `~/.xsession` to launch `xfce4-session`, which in turn
            # launches `xfdesktop`, `xmonad`, `xfce4-panel` etc.
            #
            # However, we also want to use the home-manager xmonad derivation
            # instead of writing our own, since it wraps up the installation in
            # nice configuration options and sets up recompilation when `xmonad.hs`
            # changes on reconciliation.
            # https://github.com/nix-community/home-manager/blob/master/modules/services/window-managers/xmonad.nix
            #
            # The home-manager xmonad derivation explicitly sets up
            # `windowManager.command`, which is what is launched by `.xsession`, so
            # we have to juggle things to get the configuration we want.

            initExtra = let
              xmonad = util.findPackage userCfg.home.packages "xmonad-with-packages";
            in ''
              # We only really need to run this once.
              xfconf-query -c xfce4-session -p /general/SaveOnExit -s false

              # ${xmonad}/bin/xmonad
            '';

            # Override (with `mkForce`) to make `~/.xsession` launch xfce4-session
            # instead of xmonad directly
            windowManager.command = pkgs.lib.mkForce "${pkgs.runtimeShell} ${pkgs.xfce.xfce4-session.xinitrc}";

            windowManager.xmonad = {
              enable = true;
              enableContribAndExtras = true;
              extraPackages = haskellPkgs: with haskellPkgs; [
                dbus
              ];
              config = ./xmonad.hs;
            };
          };
        };
      };
    }

    (mkIf cfg.rootDevice.isSolidState {
      fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];
    })
  ]);
}
