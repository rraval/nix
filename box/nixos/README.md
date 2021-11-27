This directory contains nix expressions that produce NixOS configuration
attrsets (i.e. usable inside specific `config.<whatever>` blocks).

Each expression must be callable by `importNixOS` as defined by
[`box/default.nix`](../box/default.nix).
