{ lib, rustPlatform, fetchFromGitHub }: rustPlatform.buildRustPackage rec {
  pname = "git-nomad";
  version = "0.6.0";

  src = fetchFromGitHub {
    owner = "rraval";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-1PXAdXafkPOIVzaWjW/RlWHwYhMqPoj0Hj5JmOMUj8A=";
  };

  cargoHash = "sha256-ULcdJRla1JwI0y6ngW9xQXjNw2wO48HuAczsNIsJJK0=";

  meta = with lib; {
    homepage = "https://github.com/rraval/git-nomad";
    description = "Synchronize work-in-progress git branches in a light weight fashion.";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
