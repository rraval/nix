{ lib, rustPlatform, fetchFromGitHub }: rustPlatform.buildRustPackage rec {
  pname = "git-nomad";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "rraval";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-kcobNP+xEu/nmJplcWNHBnft8/BpwIph6o/JcUiHk60=";
  };

  cargoHash = "sha256-OY5QHoLxU/e3eVzflQCrXXFRqimB5GKGKAcIYhVcAU4=";

  meta = with lib; {
    homepage = "https://github.com/rraval/git-nomad";
    description = "Synchronize work-in-progress git branches in a light weight fashion.";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
