{ lib, rustPlatform, fetchFromGitHub }: rustPlatform.buildRustPackage rec {
  pname = "git-nomad";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "rraval";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-PsPmBzv3LD2amiEQtbYOs6M3GPfLOLxXpY4ST7bzBXw=";
  };

  cargoHash = "sha256-YrEfklU0w+zaL/4S2W0WcLH5DrHFSicMtew8lzunjxg=";

  meta = with lib; {
    homepage = "https://github.com/rraval/git-nomad";
    description = "Synchronize work-in-progress git branches in a light weight fashion.";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
