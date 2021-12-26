{ lib, rustPlatform, fetchFromGitHub }: rustPlatform.buildRustPackage rec {
  pname = "git-nomad";
  version = "0.4.0";

  src = fetchFromGitHub {
    owner = "rraval";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-gk4alpi6BHJ0qVM1UJlQe7mzFpmUKy3smLNOhuviENg=";
  };

  cargoHash = "sha256-C3ATVXt5gFvGBLRoIjYp8UilvAJG31WW9CR94nV+gFc=";

  meta = with lib; {
    homepage = "https://github.com/rraval/git-nomad";
    description = "Synchronize work-in-progress git branches in a light weight fashion.";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
