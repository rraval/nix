{ pkgs, ... }: let
  postgresqlPkg = pkgs.postgresql_11;
  mkDbExtension = name: pkgs.stdenv.mkDerivation {
    name = "encircle-postgresql-db-extension-${name}";
    src = ./archive.tar.xz;
    buildInputs = [ postgresqlPkg ];
    postUnpack = ''
      sourceRoot="$sourceRoot"/${name}
    '';
    installPhase = ''
      mkdir -p $out/{lib,share/postgresql/extension}
      cp *.so $out/lib
      cp *.sql $out/share/postgresql/extension
      cp *.control $out/share/postgresql/extension
    '';
  };
in {
  enable = true;
  package = postgresqlPkg;
  initdbArgs = [ "--locale" "C" "-E" "UTF8" ];
  settings = {
    TimeZone = "UTC";
  };
  authentication = "local all all trust";
  ensureUsers = [{
    name = "encircle";
    # FIXME: no way to grant CREATEDB
    # https://github.com/NixOS/nixpkgs/blob/39e6bf76474ce742eb027a88c4da6331f0a1526f/nixos/modules/services/databases/postgresql.nix#L381
  }];
  extraPlugins = builtins.map mkDbExtension [
    "encircle_parser"
    "encircle_snowball"
    "unnegate"
  ];
}
