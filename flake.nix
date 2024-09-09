{
  description = "rraval's standardized productive machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    rravalNixPrivate = {
      url = "github:rraval/nix-private";
    };
    homeManager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gitNomad = {
      url = "github:rraval/git-nomad";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    encircle = {
      url = "github:EncircleInc/nix-configs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      rravalNixPrivate,
      homeManager,
      gitNomad,
      encircle,
    }:
    let
      boxModule = {
        imports = [
          homeManager.nixosModule
          ./box
        ];
      };

      mkHost =
        hostName: hostModule:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";

          modules = [
            {
              imports = [ hostModule ];

              networking.hostName = hostName;
              i18n.defaultLocale = "en_CA.UTF-8";
              time.timeZone = "America/Toronto";
            }

            (
              { pkgs, ... }:
              {
                # FIXME: it would be nice for gitNomad to provide an overlay
                nixpkgs.overlays = [ (final: prev: { git-nomad = gitNomad.packages.${pkgs.system}.default; }) ];
              }
            )

            (
              { pkgs, ... }:
              {
                imports = [ boxModule ];

                box.user = {
                  login = {
                    name = "rraval";
                    hashedPassword = rravalNixPrivate.data.rravalHashedPasswd;
                  };

                  realName = "Ronuk Raval";
                  email = "ronuk.raval@gmail.com";
                };
              }
            )

            {
              imports = [ encircle.nixosModules.default ];

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
        };

      mkAllHosts = hostAttrs: builtins.mapAttrs mkHost hostAttrs;
    in
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;

      nixosConfigurations = mkAllHosts {
        apollo =
          { pkgs, lib, ... }:
          {
            box.disks = {
              decrypted0 = {
                encryptedDevice = "/dev/disk/by-uuid/270f43d6-38dd-4f81-b155-fe20fece7a38";
                isSolidState = true;
              };
              decrypted1 = {
                encryptedDevice = "/dev/disk/by-uuid/532bf1c6-a46a-48a8-acaa-1d4764ea63d3";
                isSolidState = true;
              };
            };

            boot.initrd.availableKernelModules = [
              "xhci_pci"
              "ahci"
              "usb_storage"
              "usbhid"
              "sd_mod"
            ];
            boot.initrd.kernelModules = [ "dm-snapshot" ];
            boot.kernelModules = [ "kvm-amd" ];
            boot.extraModulePackages = [ ];

            fileSystems."/" = {
              device = "/dev/disk/by-uuid/db5d566d-d9cd-4c9c-9ccc-fffe5b841254";
              fsType = "ext4";
            };

            fileSystems."/boot" = {
              device = "/dev/disk/by-uuid/4805-1D03";
              fsType = "vfat";
            };

            swapDevices = [ ];

            # AMD Radeon RX 5600 XT fixes
            # FIXME: the patch doesn't apply cleanly on latest kernel versions.
            # boot.kernelPatches = [
            #   {
            #     name = "amdgpu-sleep-fix";
            #     patch = ./workaround/amdgpu-sleep-fix.patch;
            #   }
            # ];
          };

        boreas =
          { pkgs, lib, ... }:
          {
            box.disks = {
              decrypted0 = {
                encryptedDevice = "/dev/disk/by-uuid/c6bf32b5-0cb2-4e5b-bdce-9725edb726d0";
                isSolidState = true;
              };
            };

            boot.initrd.availableKernelModules = [
              "xhci_pci"
              "ahci"
              "nvme"
              "usb_storage"
              "sd_mod"
            ];
            boot.initrd.kernelModules = [ "dm-snapshot" ];
            boot.kernelModules = [ "kvm-intel" ];
            services.xserver.videoDrivers = [ "i915" ];

            fileSystems."/" = {
              device = "/dev/disk/by-uuid/f6ac1773-1350-4113-bad1-e31f79ce4e94";
              fsType = "ext4";
            };

            fileSystems."/boot" = {
              device = "/dev/disk/by-uuid/02EA-5E31";
              fsType = "vfat";
            };

            swapDevices = [ ];

            # Lenovo E15 additions
            powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
            hardware.firmware = [
              (pkgs.writeTextDir "/lib/firmware/hda-jack-retask.fw" (
                builtins.readFile ./workaround/e15-hda-jack-retask.fw
              ))
            ];
            boot.extraModprobeConfig = ''
              options snd-hda-intel patch=hda-jack-retask.fw
            '';
          };

        clio =
          { pkgs, lib, ... }:
          {
            box.disks = {
              decrypted0 = {
                encryptedDevice = "/dev/disk/by-uuid/aeb64845-315b-4c27-9a20-edbe5b4dc8da";
                isSolidState = true;
              };
            };

            boot.initrd.availableKernelModules = [
              "xhci_pci"
              "nvme"
              "usb_storage"
              "sd_mod"
              "rtsx_pci_sdmmc"
            ];
            boot.initrd.kernelModules = [ "dm-snapshot" ];
            boot.kernelModules = [ "kvm-intel" ];
            services.xserver.videoDrivers = [ "i915" ];

            fileSystems."/" = {
              device = "/dev/disk/by-uuid/1fd546c1-8371-4f18-b20d-422f86c65af3";
              fsType = "ext4";
            };

            fileSystems."/boot" = {
              device = "/dev/disk/by-uuid/2527-B279";
              fsType = "vfat";
            };

            swapDevices = [ ];

            powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
            # Maybe needed?
            # hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
          };
      };
    };
}
