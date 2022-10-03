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

## Secrets

There's two layers of "secrets" in this repository:

1. Secret code, needed at evaluation time, which involves Nix derivations that I'd rather not publish publicly. These are managed by a private Git repo: https://github.com/rraval/nix-private; which is an input to this flake.

2. Secret credentials, needed at run time by various services on the system. These are currently unmanaged by Nix and have to be manually created.

FIXME: agenix might be a good solution for (2), though it'll have to be untangled with the `nix-private` concerns in (1).
