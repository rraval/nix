{ config, ... }: let
  userCfg = config.box.user;
in {
  programs.git = {
    enable = true;
    userName = userCfg.realName;
    userEmail = userCfg.email;
    extraConfig = {
      color = {
        diff = "auto";
        status = "auto";
        branch = "auto";
      };
      core = {
        whitespace = "trailing-space,space-before-tab";
        pager = "delta";
      };
      commit = {
        cleanup = "scissors";
      };
      branch = {
        autoSetupMerge = "simple";
      };
      interactive = {
        diffFilter = "delta --color-only";
      };
      delta = {
        navigate = "true";
        hyperlinks = "true";
      };
      apply = {
        whitespace = "fix";
      };
      push = {
        default = "current";
      };
      rebase = {
        autosquash = true;
        stat = true;
        missingCommitsCheck = "warn";
      };
      merge = {
        conflictstyle = "diff3";
      };
      diff = {
        colorMoved = "default";
      };
    };
    aliases = {
      an = "add -N .";
      ap = "add -p";
      com = "commit";
      mcom = "merge --no-ff";
      acom = "commit --allow-empty --amend";
      sep = "commit --allow-empty -m ------";

      st = "status -sb";
      cached = "diff --cached";
      stat = "diff --stat";
      graph = "log --graph --oneline --all --decorate";
      g = "!git log --branches --graph --decorate --oneline --not $(git show-ref --heads --hash | xargs git merge-base --octopus)";

      ri = "rebase --interactive";
      cont = "rebase --continue";
      todo = "rebase --edit-todo";

      d = "switch --detach";
      b = "branch";
      bd = ''!n=$(git symbolic-ref --short HEAD) && git switch --detach && git branch -D "$n"'';
      to = "branch --set-upstream-to";
      br = "for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:green)%(refname:short)%(color:reset): %(color:red)%(objectname:short)%(color:reset) %(contents:subject) %(color:yellow)(%(authorname) %(committerdate:relative))%(color:reset)'";
      nr = "!git for-each-ref --sort=committerdate refs/nomad/ --exclude \"refs/nomad/$(hostname)/**\" --format='%(HEAD) %(color:green)%(refname:strip=3)%(color:reset): %(color:red)%(objectname:short)%(color:reset) %(contents:subject) %(color:yellow)(%(authorname) %(committerdate:relative))%(color:reset)'";
      co = "checkout";
      cx = "cherry-pick -x";
      fliptable = "!echo '(╯°□°）╯︵ ┻━┻'; git reset --hard HEAD";
      flipup = "!echo '┬─┬ ノ( ゜-゜ノ)'; git reset --hard '@{u}'";

      f = "fetch";
      up = "pull --rebase=merges";
      ff = "merge --ff-only";
      mm = "!git fetch origin && git merge origin/master";
    };
  };
}
