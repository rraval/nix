This directory contains nix expressions for ad-hoc packages that are not (yet)
available on nixpkgs.

Each expression must be callable by `nixpkgs.pkgs.callPackage`.

Ideally, this directory acts as staging until the packages defined here can be
upstreamed into nixpkgs.
