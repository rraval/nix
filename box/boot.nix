{ config, ... }:
let
  cfg = config.box;
in
{
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
}
