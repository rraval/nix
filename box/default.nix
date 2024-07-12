{ pkgs, lib, config, boxArgs, ... }: let
  inherit (boxArgs)
    user
    locale
    timeZone
    hostName
    rootDisks
    rravalSha256Passwd
  ;

  inherit (lib)
    concatMapAttrs
    mkIf
    mkMerge
    optional
  ;

  hmCfg = config.home-manager.users.${user.name};
  homeDir = hmCfg.home.homeDirectory;

  env = let
    importPkg = name: pkgs.callPackage (./packages + "/${name}.nix") {};
    importPkgList = names: lib.genAttrs names importPkg;
  in {
    inherit user;
    pkgs = pkgs // (importPkgList [
    ]);
  };

  importNixOS = name: import (./nixos + "/${name}") env;
in mkMerge [
  {
    nix = {
      settings.allowed-users = [ user.name ];
      package = pkgs.nixUnstable;
      extraOptions = ''
        experimental-features = nix-command flakes
        !include /etc/nix/extra-nix.conf
      '';
    };
    nixpkgs.config.allowUnfree = true;
    time.timeZone = timeZone;
    system.stateVersion = "20.09";

    networking = {
      # global useDHCP is deprecated, don't use it
      useDHCP = false;

      inherit hostName;

      networkmanager.enable = true;

      firewall.allowedTCPPorts = [
        # for VLC Chromecast integration, see
        # https://github.com/NixOS/nixpkgs/blob/c207be6/pkgs/applications/video/vlc/default.nix#L20
        8010

        # HTTP servers for local development
        8888
      ];
      firewall.allowedUDPPortRanges = [ { from = 32768; to = 60999; } ];
    };

    powerManagement.cpuFreqGovernor = "ondemand";

    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
      initrd.luks.devices = builtins.mapAttrs (diskName: diskDescription: {
        device = builtins.toString diskDescription.encryptedDisk;
        preLVM = true;
        allowDiscards = diskDescription.isSolidState;
      }) rootDisks;
    };

    i18n.defaultLocale = locale;
    console.useXkbConfig = true;
    hardware = {
      enableRedistributableFirmware = true;
      bluetooth.enable = true;
      pulseaudio = {
        enable = true;
        daemon.config = {
          flat-volumes = "no";
          realtime-scheduling = "yes";
          rlimit-rttime = -1;
          exit-idle-time = -1;
        };
      };
      sane = {
        enable = true;
        extraBackends = [ pkgs.sane-airscan ];
      };
    };

    users = {
      mutableUsers = false;

      groups.${user.name} = {
        gid = 1000;
      };

      users.${user.name} = {
        isNormalUser = true;
        uid = 1000;
        group = user.name;
        extraGroups = [
          "adbusers"
          "audio"
          "docker"
          "lp"
          "networkmanager"
          "scanner"
          "video"
          "wheel"
          "wireshark"
        ];
        hashedPassword = user.hashedPasswd;
        createHome = true;
        home = "/home/${user.name}";
        shell = pkgs.fish;
      };
    };

    virtualisation.docker.enable = true;

    services = mkMerge [
      {
        avahi = {
          enable = true;
          nssmdns = true;
        };
        blueman.enable = true;
        pcscd.enable = true;
        tailscale.enable = true;

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
    ];

    environment = {
      systemPackages = importNixOS "system-packages.nix";

      shells = [
        pkgs.fish
      ];

      variables = {
        EDITOR = "nvim";
        VISUAL = "nvim";
      };

      # Automatically load fish direnv hook
      # https://github.com/nix-community/home-manager/pull/2408#issuecomment-951079054
      pathsToLink = [ "/share/fish" ];
    };

    programs.noisetorch.enable = true;
    programs.wireshark.enable = true;
    programs.fish.enable = true;
    programs.steam.enable = true;

    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;

      users.${user.name} = {
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
            config = ./config/xmonad.hs;
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
          # FIXME: visidata stuff is spread all over the place
          # refactor to its own NixOS module
          ".visidata/plugins/dedupe.py".source = let
            vdPlugins = pkgs.fetchFromGitHub {
              owner = "jsvine";
              repo = "visidata-plugins";
              rev = "aacf35da59e72c0df20b82458aaa93f2fa1b5ff4";
              hash = "sha256-1JSP3eVtmLWFmIx+TD7aDRLx2nNeomm2+2k+r50b1U8=";
            };
          in builtins.toPath "${vdPlugins}/plugins/dedupe.py";
          ".visidatarc".text = ''
            import plugins.dedupe
          '';
        };
      };
    };
  }

  (let
    isRootSolidState =
      builtins.any
      (diskDescription: diskDescription.isSolidState)
      (builtins.attrValues rootDisks)
    ;
  in mkIf isRootSolidState {
    fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];
  })

  {
    encircle = {
      env.enable = true;
      hosts.enable = true;
      vanta.enable = true;
      postgresql.enable = true;
      vpn.enable = true;
      minikube.enable = true;
    };
  }
]
