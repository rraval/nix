{ osConfig, pkgs, ... }:
let
  userCfg = osConfig.box.user;
in
{
  home.packages = with pkgs; [
    delta
    difftastic
    git-absorb
  ];

  programs.git = {
    enable = true;
    userName = userCfg.realName;
    userEmail = userCfg.email;
    extraConfig = {
      apply.whitespace = "fix";
      branch.autoSetupMerge = "simple";
      branch.sort = "-committerdate";
      color.branch = "auto";
      color.diff = "auto";
      color.status = "auto";
      column.ui = "auto";
      commit.cleanup = "scissors";
      core.fsmonitor = true;
      core.untrackedCache = true;
      core.whitespace = "trailing-space,space-before-tab";
      diff.algorithm = "histogram";
      diff.colorMoved = "plain";
      diff.mnemonicPrefix = true;
      diff.renames = true;
      fetch.all = true;
      fetch.prune = true;
      fetch.pruneTags = true;
      help.autocorrect = "prompt";
      init.defaultBranch = "main";
      merge.conflictstyle = "zdiff3";
      merge.ff = false;
      pull.ff = true;
      push.autoSetupRemote = true;
      push.default = "current";
      push.followTags = true;
      rebase.autoStash = true;
      rebase.autoSquash = true;
      rebase.missingCommitsCheck = "warn";
      rebase.stat = true;
      rerere.autoupdate = true;
      rerere.enabled = true;
      tag.sort = "version:refname";
    };
    # Use includes to keep external tool config isolated.
    includes =
      map
        (
          { name, content }:
          {
            path = pkgs.writeText name content;
          }
        )
        [
          {
            name = "delta";
            content = ''
              [core]
                pager = delta

              [interactive]
                diffFilter = delta --color-only --features=interactive

              [delta]
                navigate = true
                hyperlinks = true

              [merge]
                conflictstyle = zdiff3

              [diff]
                colorMoved = default
            '';
          }

          {
            name = "difftastic";
            content = ''
              [diff]
                tool = difftastic

              [difftool]
                prompt = false

              [difftool "difftastic"]
                cmd = difft "$LOCAL" "$REMOTE"

              [pager]
                difftool = true
            '';
          }
        ];
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
      l = "log --oneline --decorate -100";
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
