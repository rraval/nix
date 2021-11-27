{ pkgs, lib, hmLib, user, locale, timeZone, cfg, hmCfg, homeDir, encircleRepoDir }: let
  inherit (lib)
    mkIf
    mkMerge
    optional
  ;

  env = let
    importPkg = name: pkgs.callPackage (./packages + "/${name}.nix") {};
    importPkgList = names: lib.genAttrs names importPkg;
  in {
    inherit user;
    pkgs = pkgs // (importPkgList [
      "git-nomad"
    ]);
  };

  importNixOS = name: import (./nixos + "/${name}") env;
in mkMerge [
  {
    nix = {
      allowedUsers = [ user.name ];
      package = pkgs.nixUnstable;
      extraOptions = "experimental-features = nix-command flakes";
    };
    nixpkgs.config.allowUnfree = true;
    time.timeZone = timeZone;
    system.stateVersion = "20.09";

    networking = {
      # global useDHCP is deprecated, don't use it
      useDHCP = false;

      hostName = cfg.networking.hostName;

      networkmanager.enable = true;

      # for VLC Chromecast integration, see
      # https://github.com/NixOS/nixpkgs/blob/c207be6/pkgs/applications/video/vlc/default.nix#L20
      firewall.allowedTCPPorts = [ 8010 ];
      firewall.allowedUDPPortRanges = [ { from = 32768; to = 60999; } ];
    };

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
    hardware = {
      bluetooth.enable = true;
      pulseaudio.enable = true;
      sane = {
        enable = true;
        extraBackends = [ pkgs.hplipWithPlugin ];
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
        extraGroups = [ "wheel" "audio" "video" "networkmanager" "docker" "adbusers" "scanner" "lp" ];
        hashedPassword = (import ./passwd.nix).${user.name};
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
        blueman.enable = true;
        pcscd.enable = true;

        postgresql = importNixOS "encircle-postgresql";

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

      (importNixOS "encircle-vpn")
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
    };

    home-manager = {
      useUserPackages = true;
      useGlobalPkgs = true;

      users.${user.name} = {
        home = {
          packages = importNixOS "home-packages.nix";
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

          firefox = importNixOS "firefox.nix";
          fish = importNixOS "fish.nix";
          git = importNixOS "git.nix";

          gpg = {
            enable = true;

            settings = {
              keyserver = "hkps://keys.openpgp.org";
            };

            # Use PC/SC to talk to smartcards
            # https://ludovicrousseau.blogspot.com/2019/06/gnupg-and-pcsc-conflicts.html
            scdaemonSettings.disable-ccid = true;
          };

          neovim = importNixOS "neovim.nix";

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
            userKnownHostsFile = "${homeDir}/.ssh/known_hosts ${./config/known_hosts}";
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

          polybar = importNixOS "polybar.nix";
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
          ".config/nvim/coc-settings.json".source = ./config/coc-settings.json;
          ".config/xfce4/terminal/terminalrc".source = ./config/terminalrc;
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
]
