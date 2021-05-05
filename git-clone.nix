pkgs: { url, dest }: {
  Unit = {
    Description = "git clone ${url} into ${dest}";
    After = [ "network-online.target" ];
  };
  Install = {
    WantedBy = [ "basic.target" ];
  };
  Service = {
    Type = "oneshot";
    ExecStart = let
      ssh = "${pkgs.openssh}/bin/ssh";
      git = "${pkgs.git}/bin/git";
    in toString (pkgs.writeShellScript "clone-${url}-${dest}" ''
      export GIT_SSH_COMMAND="${ssh} -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
      if [[ ! -d '${dest}' ]]; then
        ${git} clone '${url}' '${dest}'
      fi
    '');
  };
}
