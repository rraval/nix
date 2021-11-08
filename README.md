# rraval's standardized productive machine

I seriously doubt anybody else would want to use this whole sale, but it's a useful place to point people to when flexing on optimizing a process I do at most once per 18 months.

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

```nix
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
    };

    rootDevice = {
      encryptedDisk = "/dev/disk/by-uuid/...";
      isSolidState = true;
    };

    bluetooth = true;

    # These require manual work and progressive enhancement.
    toil = {
      # For example, the first run will generate SSH keys for the machine.
      # Then if you manually modify your GitHub account to trust that key, you
      # can enable this option and progressively make your way to the ideal
      # fixed point.
      sshKeyTrustedByGitHub = true;

      encircle = {
        sshKeyTrustedByPhabricator = true;
        sshIdentity = "/home/rraval/.encircle/id_rsa";
        postgresql = true;
        vpn = {
          config = "/home/rraval/.encircle/vpn.conf";
          dnsIp = "...";
        };
      };
    };
  };
}
```

## Upcoming Flakification

There is an ongoing effort to move this configuration over to nix flakes, which
involves exposing complete configurations by host name instead of the current
NixOS module API surface.

Secrets are checked right into the repo, so setup involves:

1. Cloning the repo somewhere
2. Adding a new entry under `nixosConfigurations.<hostname>` for the new host
3. Grab a shell with `nix-shell -p blackbox`
4. Run `blackbox_postdeploy`
5. Replace `/etc/nixos` to link to the cloned repo
6. Run `nixos-rebuild switch --flake /etc/nixos#<hostname>`
