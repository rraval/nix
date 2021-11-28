{
  description = "rraval's standardized productive machines";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }: let
    mkBox = (import ./box) { inherit nixpkgs home-manager; };
  in {
    nixosConfigurations = builtins.listToAttrs [
      (mkBox {
        hostName = "boreas";
        rootDevice = {
          encryptedDisk = "/dev/disk/by-uuid/c6bf32b5-0cb2-4e5b-bdce-9725edb726d0";
          isSolidState = true;
        };
        extraModules = [
          ({ pkgs, modulesPath, ... }: {
            boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" ];
            boot.initrd.kernelModules = [ "dm-snapshot" ];
            boot.kernelModules = [ "kvm-intel" ];
            services.xserver.videoDrivers = [ "i915" ];
            boot.extraModulePackages = [ ];

            fileSystems."/" = {
              device = "/dev/disk/by-uuid/f6ac1773-1350-4113-bad1-e31f79ce4e94";
              fsType = "ext4";
            };

            fileSystems."/boot" = {
              device = "/dev/disk/by-uuid/02EA-5E31";
              fsType = "vfat";
            };

            swapDevices = [ ];

            # Lenovo E15 has issues plugging in headphones, use a very specific
            # retasking to fix tings:
            hardware.firmware = [
              (pkgs.writeTextDir "/lib/firmware/hda-jack-retask.fw" (builtins.readFile ./hda-jack-retask.fw))
            ];
            boot.extraModprobeConfig = ''
              options snd-hda-intel patch=hda-jack-retask.fw
            '';
          })
        ];
      })
    ];
  };
}
