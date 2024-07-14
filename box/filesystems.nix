{ lib, config, ... }: let
  isRootSolidState =
    builtins.any
    (diskDescription: diskDescription.isSolidState)
    (builtins.attrValues config.box.disks)
  ;
in lib.mkIf isRootSolidState {
  fileSystems."/".options = [ "noatime" "nodiratime" "discard" ];
}
