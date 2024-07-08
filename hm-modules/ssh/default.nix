{ lib, config, ... }: {
  programs.ssh = {
    enable = true;
    userKnownHostsFile = "${config.home.homeDirectory}/.ssh/known_hosts ${./known_hosts}";
    serverAliveInterval = 60;
  };

  # Automatically generate (user + node) specific SSH keys.
  # FIXME: stop using $DRY_RUN_CMD
  # https://nix-community.github.io/home-manager/release-notes.xhtml#sec-release-24.05-highlights
  home.activation.sshKeygen = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [[ ! -f "$HOME"/.ssh/id_rsa ]]; then
      $DRY_RUN_CMD ssh-keygen -b 4096 -f "$HOME"/.ssh/id_rsa -N ""
    fi
  '';
}
