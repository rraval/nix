{ ... }: let
  vpnDnsIp = "10.3.1.5";
  minikubeDnsIp = "192.168.49.2";
in {
  dnsmasq = {
    enable = true;
    extraConfig = ''
      server=/encirclestaging.com/${vpnDnsIp}
      server=/encircleproduction.com/${vpnDnsIp}
      server=/encircle.local/${minikubeDnsIp}
    '';
  };

  openvpn.servers.encircle = {
    config = "config ${./vpn.conf}";
  };
}
