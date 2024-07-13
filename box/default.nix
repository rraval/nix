{ pkgs, lib, config, ... }: let
  inherit (lib)
    concatMapAttrs
    mkIf
    mkMerge
    optional
  ;

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
            encryptedDevice = "/dev/disk/by-uuid/00000000-0000-0000-0000-000000000000";
            isSolidState = true;
          };
        };
      };
    };
  };

  config = mkMerge [
    {
      nix = {
        settings.allowed-users = [ user ];
        package = pkgs.nixUnstable;
        extraOptions = ''
          experimental-features = nix-command flakes
          !include /etc/nix/extra-nix.conf
        '';
      };
      nixpkgs.config.allowUnfree = true;
      system.stateVersion = "20.09";

      networking = {
        # global useDHCP is deprecated, don't use it
        useDHCP = false;

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
          device = builtins.toString diskDescription.encryptedDevice;
          preLVM = true;
          allowDiscards = diskDescription.isSolidState;
        }) cfg.disks;
      };

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

        groups.${user} = {
          gid = 1000;
        };

        users.${user} = {
          isNormalUser = true;
          uid = 1000;
          group = user;
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
          hashedPassword = cfg.user.login.hashedPassword;
          createHome = true;
          home = "/home/${user}";
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
        systemPackages = with pkgs; [
          fish
          git
          neovim
        ];

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
    }

    (let
      isRootSolidState =
        builtins.any
        (diskDescription: diskDescription.isSolidState)
        (builtins.attrValues cfg.disks)
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
  ];
}
