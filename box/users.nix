{ config, pkgs, ... }: let
  loginCfg = config.box.user.login;
in {
  users = {
    mutableUsers = false;

    groups.${loginCfg.name} = {
      gid = 1000;
    };

    users.${loginCfg.name} = {
      isNormalUser = true;
      uid = 1000;
      group = loginCfg.name;
      extraGroups = [ "wheel" ];
      hashedPassword = loginCfg.hashedPassword;
      createHome = true;
      home = "/home/${loginCfg.name}";
      shell = pkgs.fish;
    };
  };
}
