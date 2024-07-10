{
  programs.gpg = {
    enable = true;

    settings = {
      keyserver = "hkps://keys.openpgp.org";
    };

    # Use PC/SC to talk to smartcards
    # https://ludovicrousseau.blogspot.com/2019/06/gnupg-and-pcsc-conflicts.html
    scdaemonSettings.disable-ccid = true;
  };
}
