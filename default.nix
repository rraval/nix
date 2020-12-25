# The canonical NixOS machine for rraval.
#
# Setup to use UEFI with a single LUKS encrypted disk with LVM on the inside.
# Filesystem options are tuned for SSDs.
#
# TODO: Turn this into a nix flake.
#
# TODO: Put home-manager dependency in this file.
#
# TODO: XFCE stop session autosave. Fully manage session configuration. XFCE start xmonad.
#
# TODO: Integrate all other dotfiles.
{
  # string: The `nixos-option networking.hostname` for this machine.
  hostName,

  # string: The SHA256 hash of the login password. Separated out to prevent it
  # being checked into Git.
  rravalHashedPassword,

  # path: Something like `/dev/disk/by-uuid/...` that points to the encrypted
  # disk device.
  encryptedDisk,

  # The `<nixpkgs>` set to work off. Should be `nixos-unstable`.
  pkgs,
  config,
}: let
  util = import ./util.nix;
  userCfg = config.home-manager.users.rraval;
in {
  nixpkgs.config.allowUnfree = true;
  networking.hostName = hostName;
  time.timeZone = "America/Toronto";
  system.stateVersion = "20.09";
  nix.allowedUsers = [ "rraval" ];

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    initrd.luks.devices = {
      decrypted0 = {
        device = (
          assert builtins.pathExists encryptedDisk;
          builtins.toString encryptedDisk
        );
        preLVM = true;
        allowDiscards = true;
      };
    };
  };

  # SSD tuning
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];

  # global useDHCP is deprecated
  networking.useDHCP = false;

  i18n.defaultLocale = "en_CA.UTF-8";
  console.useXkbConfig = true;

  users = {
    mutableUsers = false;

    groups.rraval = {
      gid = 1000;
    };

    users.rraval = {
      isNormalUser = true;
      uid = 1000;
      group = "rraval";
      extraGroups = [ "wheel" ];
      hashedPassword = rravalHashedPassword;
      createHome = true;
      home = "/home/rraval";
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

    users.rraval = {
      programs = {
        firefox = {
          enable = true;
        };

        fish = {
          enable = true;
        };

        git = {
          enable = true;
          userName = "Ronuk Raval";
          userEmail = "ronuk.raval@gmail.com";
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

      xsession = {
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
