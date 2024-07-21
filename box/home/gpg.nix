{ pkgs, ... }: {
  programs.gpg = {
    enable = true;

    settings = { keyserver = "hkps://keys.openpgp.org"; };

    # Use PC/SC to talk to smartcards
    # https://ludovicrousseau.blogspot.com/2019/06/gnupg-and-pcsc-conflicts.html
    scdaemonSettings.disable-ccid = true;
  };

  services.gpg-agent = let hour_in_seconds = 60 * 60;
  in {
    enable = true;
    pinentryPackage = pkgs.pinentry-gtk2;
    enableSshSupport = true;
    defaultCacheTtl = hour_in_seconds;
    maxCacheTtl = 2 * hour_in_seconds;
    defaultCacheTtlSsh = 4 * hour_in_seconds;
    maxCacheTtlSsh = 12 * hour_in_seconds;
    extraConfig = ''
      auto-expand-secmem 0x30000
    '';
  };
}
