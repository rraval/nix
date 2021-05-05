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
      if [[ ! -d '${dest}' ]]; then
        GIT_SSH_COMMAND="${ssh} -o StrictHostKeyChecking=yes" ${git} clone '${url}' '${dest}'
      fi
    '');
  };
}
