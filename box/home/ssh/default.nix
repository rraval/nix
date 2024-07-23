{ lib, config, ... }:
{
  programs.ssh = {
    enable = true;
    userKnownHostsFile = "${config.home.homeDirectory}/.ssh/known_hosts ${./known_hosts}";
    serverAliveInterval = 60;
  };

  # Automatically generate (user + node) specific SSH keys.
  home.activation.sshKeygen = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [[ ! -f "$HOME"/.ssh/id_rsa ]]; then
      run ssh-keygen -b 4096 -f "$HOME"/.ssh/id_rsa -N ""
    fi
  '';
}
