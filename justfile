_default:
    just --list

switch:
    nixos-rebuild switch --use-remote-sudo --flake 'path:{{justfile_directory()}}'

fmt:
    nix fmt .
