This directory contains [Home Manager Modules](https://nix-community.github.io/home-manager/index.xhtml#ch-writing-modules):

- Should be specified as `imports` under a `home-manager.users.<name>`
  configuration.
    - That same `home-manager.users.<name>` configuration should be passed in
      as `config`.
- Other module arguments like `lib` and `pkgs` should be augmented with
  home-manager additions.
