{ lib, rustPlatform, fetchFromGitHub }: rustPlatform.buildRustPackage rec {
  pname = "git-nomad";
  version = "0.3.2";

  src = fetchFromGitHub {
    owner = "rraval";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-+3nuivxCIhIGuPkVQQ2lZULC4Pj3PLftIF9O8SdwazM=";
  };

  cargoHash = "sha256-NOyJonZX0fVe5DKTXvH/GunI8+WRyKthaxHlI88qH6k=";

  meta = with lib; {
    homepage = "https://github.com/rraval/git-nomad";
    description = "Synchronize work-in-progress git branches in a light weight fashion.";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
