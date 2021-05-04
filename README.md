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
    /path/to/rraval-nix
  ];

  rravalBox = {
    enable = true;

    # ... more configuration
  };
}
```

The bootstrapping process may require progressive enhancement, for example, the first go around will generate ssh keys for the machine. Then, if you add those keys to your GitHub account, then `rravalBox.cloneRepositoriesFrom.github = true;` will start cloning private repos to setup encrypted passwords.
