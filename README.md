# rraval's standardized productive machines

I seriously doubt anybody else would want to use this whole sale, but it's a useful place to point people to when flexing on optimizing a process I do at most once per 18 months.

## Setting up a new box

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

Modify `rraval-nix/flake.nix` to include a configuration for the new host (`nixos-generate-config --show-hardware-config` can help).

Finally, run:

```
$ nixos-rebuild switch --flake path:/to/rraval-nix#hostname
```
