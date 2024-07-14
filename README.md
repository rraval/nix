# rraval's nix config

[NixOS configurations](https://nixos.wiki/wiki/Overview_of_the_NixOS_Linux_distribution)
for all of my machines as a single [Nix flake](https://nixos.wiki/wiki/Flakes).

> [!NOTE]
>
> This repo mostly exists as a useful place to point people to when trying to
> explain how I've configured a certain thing.
>
> Using it directly is unlikely to work out for you.

# Structure

`flake.nix` defines `nixosConfigurations` for each computer I currently have.

- The `box` folder contains [NixOS modules](https://nixos.wiki/wiki/NixOS_modules)
  that configure the OS as a single user system.

    - This module reserves the `box` configuration namespace for its use.

    - It also contains the `home` sub-folder that contains
      [Home Manager Modules](https://nix-community.github.io/home-manager/index.xhtml#ch-writing-modules)
      that configure the single user home directory.

        - Most programs are installed and configured at this level instead of
          being installed system wide.

- The `workaround` folder holds patches and other files to address system specific issues.

# Usage

Go to GitHub Settings > Developer Settings > Personal Access Tokens > Generate New Token.

Generate a new token for `<machine> nix`.

Then drop a file into /etc/nix/extra-nix.conf

```
extra-access-tokens = github.com=<token>
```

---

Clone this repo somewhere like:

```
$ git clone https://github.com/rraval/nix.git rraval-nix
```

Modify `rraval-nix/flake.nix` to include a configuration for the new host
(`nixos-generate-config --show-hardware-config` can help).

Finally, run:

```
$ nixos-rebuild switch --flake path:/to/rraval-nix#hostname
```
