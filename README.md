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

    networking = {
      hostName = "apollo";
    };

    rootDevice = {
      encryptedDisk = "/dev/disk/by-uuid/...";
      isSolidState = true;
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
