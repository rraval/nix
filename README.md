# rraval's standardized productive machine

## Usage

To set up a new box, first get the right channels (someday we'll use flakes and this part will go away):

```
$ sudo nix-channel --add https://nixos.org/channels/nixos-unstable nixos
$ sudo nix-channel --add https://github.com/nix-community/home-manager/archive/master.tar.gz home-manager
$ sudo nix-channel --update
```

Then clone this repo somewhere like:

```
$ git clone https://github.com/rraval/nix.git rraval-nix
```

And finally, modify `/etc/nixos/configuration.nix`:

```
{ ... }: {
  imports = [
    <home-manager/nixos>
    ./hardware-configuration.nix
    /path/to/rraval-nix  # Modify this to point to a checkout
  ];

  rravalBox = {
    enable = true;

    system = {
      locale = "en_CA.UTF-8";
      timeZone = "America/Toronto";
    };

    user = {
      name = "rraval";
      sha256Password = "...";
      realName = "Ronuk Raval";
      email = "ronuk.raval@gmail.com";
    };

    networking = {
      hostName = "apollo";
      wiredEthernet = "enp6s0";
    };

    rootDevice = {
      encryptedDisk = "/dev/disk/by-uuid/...";
      isSolidState = true;
    };

    bluetooth = true;

    toil = {
      sshKeyTrustedByGitHub = true;
      encircle = {
        sshKeyTrustedByPhabricator = true;
        vpn = {
          config = "/home/rraval/.encircle/vpn.conf";
          dnsIp = "...";
        };
      };
    };
  };
}
```

The `rravalBox.toil` options require manual work and progressive enhancement. For example, the first run will generate SSH keys for the machine. Then if you manually modify your GitHub account to trust that SSH key, you can enable `rravalBox.toil.sshKeyTrustedByGitHub` and progressively make your way to the ideal fixed point.
