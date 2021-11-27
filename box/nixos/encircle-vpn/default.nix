{ ... }: let
  dnsIp = "10.3.1.5";
in {
  dnsmasq = {
    enable = true;
    extraConfig = ''
      server=/encirclestaging.com/${dnsIp}
      server=/encircleproduction.com/${dnsIp}
    '';
  };

  openvpn.servers.encircle = {
    config = "config ${./vpn.conf}";
  };
}
