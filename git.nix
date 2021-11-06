{ name, email }: {
  enable = true;
  userName = name;
  userEmail = email;
  extraConfig = {
    color = {
      diff = "auto";
      status = "auto";
      branch = "auto";
    };
    core = {
      whitespace = "trailing-space,space-before-tab";
      commentChar = ";";
    };
    apply = {
      whitespace = "fix";
    };
    branch = {
      autoSetupMerge = "always";
    };
    push = {
      default = "simple";
    };
    rebase = {
      autosquash = true;
      stat = true;
      missingCommitsCheck = "warn";
    };
    merge = {
      tool = "splice";
      conflictstyle = "diff3";
    };
    mergetool = {
      keepBackup = false;
      splice = {
        cmd = "nvim -f $BASE $LOCAL $REMOTE $MERGED -c 'SpliceInit'";
        trustExitCode = true;
      };
    };
  };
  aliases = {
    an = "add -N .";
    ap = "add -p";
    com = "commit";
    mcom = "merge --no-ff";
    acom = "commit --amend";

    st = "status -sb";
    d = "diff";
    cached = "diff --cached";
    stat = "diff --stat";
    graph = "log --graph --oneline --all --decorate";
    g = "!git log --branches --graph --decorate --oneline --not $(git show-ref --heads --hash | xargs git merge-base --octopus)";

    ri = "rebase --interactive";
    cont = "rebase --continue";
    todo = "rebase --edit-todo";

    b = "branch";
    to = "branch --set-upstream-to";
    tom = "branch --set-upstream-to origin/master";
    br = "for-each-ref --sort=committerdate refs/heads/ --format='%(HEAD) %(color:green)%(refname:short)%(color:reset): %(color:red)%(objectname:short)%(color:reset) %(contents:subject) %(color:yellow)(%(authorname) %(committerdate:relative))%(color:reset)'";
    co = "checkout";
    cob = "!git checkout -b $1 origin/master #";
    cx = "cherry-pick -x";
    fliptable = "!echo '(╯°□°）╯︵ ┻━┻'; git reset --hard HEAD";
    flipup = "!echo '┬─┬ ノ( ゜-゜ノ)'; git reset --hard '@{u}'";

    up = "pull --rebase=merges";
    ff = "merge --ff-only";
  };
}
