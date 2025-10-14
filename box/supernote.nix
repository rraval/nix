{
  services.xserver.wacom.enable = true;
  environment.etc."X11/xorg.conf.d/10-supernote.conf".text = ''
    Section "InputClass"
      Identifier "Supernote Tablet"
      Driver "wacom"
      MatchDevicePath "/dev/input/event*"
      MatchUSBID "2207:0007"
    EndSection
  '';
}
