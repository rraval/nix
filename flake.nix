{
  description = "rraval's standardized productive machine";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager }: {
    nixosModule = {
      imports = [
        home-manager.nixosModules.home-manager
        ./default.nix
      ];
    };
  };
}
