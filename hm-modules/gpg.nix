{ lib, config, ... }: {
  programs.gpg = {
    enable = true;

    settings = {
      keyserver = "hkps://keys.openpgp.org";
    };

    # Use PC/SC to talk to smartcards
    # https://ludovicrousseau.blogspot.com/2019/06/gnupg-and-pcsc-conflicts.html
    scdaemonSettings.disable-ccid = true;
  };

  # FIXME: this should no longer be needed
  # https://github.com/nix-community/home-manager/commit/399a3dfeafa7328f40b99759d94d908185ce72a6

  # Set safe permissions on GPG homedir
  # From https://logs.nix.samueldr.com/home-manager/2020-11-12
  #
  # 08:17 <coco> For gpg, I get "gpg: WARNING: unsafe permissions on
  # homedir '/home/<user>/.gnupg'". I can perform a `chmod go-rwx`
  # to fix this, but is there a declarative way to do that?
  #
  # 11:22 <hexa-> chmod 700 ~/.gnupg
  #
  # 11:22 <hexa-> and be done
  #
  # 11:28 <piegames1> coco: As the folder itself is not really part
  # of any declarativeness, you only need to run the command once
  # and be done.

  # FIXME: stop using $DRY_RUN_CMD
  # https://nix-community.github.io/home-manager/release-notes.xhtml#sec-release-24.05-highlights
  home.activation.gpgPermissions = lib.hm.dag.entryAfter ["writeBoundary"] ''
    $DRY_RUN_CMD chmod 700 ${config.programs.gpg.homedir}
  '';
}
