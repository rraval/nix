_default:
    just --list

dry-build *args="":
    nixos-rebuild dry-build --sudo --flake 'path:{{justfile_directory()}}' {{args}}

build *args="":
    nixos-rebuild build --sudo --flake 'path:{{justfile_directory()}}' {{args}}

switch:
    nixos-rebuild switch --sudo --flake 'path:{{justfile_directory()}}'

switch_override:
    nixos-rebuild switch --sudo --flake 'path:{{justfile_directory()}}' --override-input encircle 'path:{{justfile_directory()}}/../encircle-nix-configs'

fmt:
    nix fmt .
