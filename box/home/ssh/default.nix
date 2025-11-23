{ lib, config, ... }:
{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "*" = {
        userKnownHostsFile = "${config.home.homeDirectory}/.ssh/known_hosts ${./known_hosts}";
        serverAliveInterval = 60;

        # Defaults from previous versions of the SSH module.
        forwardAgent = false;
        addKeysToAgent = "no";
        compression = false;
        serverAliveCountMax = 3;
        hashKnownHosts = false;
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };
    };
  };

  # Automatically generate (user + node) specific SSH keys.
  home.activation.sshKeygen = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [[ ! -f "$HOME"/.ssh/id_rsa ]]; then
      run ssh-keygen -b 4096 -f "$HOME"/.ssh/id_rsa -N ""
    fi
  '';
}
