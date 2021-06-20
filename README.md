# rraval's standardized productive machine

I seriously doubt anybody else would want to use this whole sale, but it's a useful place to point people to when flexing on optimizing a process I do at most once per 18 months.

## Usage

To set up a new box:

```
# FIXME: nixos-minimal ISO commands here
```

Then modify `/etc/nixos/flake.nix` (for hostname `apollo`):

```nix
{
  inputs = {
    nixpkgs.follows = "rravalBox/nixpkgs";
    rravalBox.url = "/home/rraval/nix";
  };

  outputs = { self, nixpkgs, rravalBox }: {
    nixosConfigurations.apollo = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        rravalBox.nixosModule
        ./hardware-configuration.nix
        {
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
          }
        }
      ];
    };
  };
}
```
