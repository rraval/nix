_default:
    just --list

build:
    nixos-rebuild build --use-remote-sudo --flake 'path:{{justfile_directory()}}'

switch:
    nixos-rebuild switch --use-remote-sudo --flake 'path:{{justfile_directory()}}'

switch_override:
    nixos-rebuild switch --use-remote-sudo --flake 'path:{{justfile_directory()}}' --override-input encircle 'path:{{justfile_directory()}}/../encircle-nix-configs'

fmt:
    nix fmt .
