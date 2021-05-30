{ lib, rustPlatform, fetchFromGitHub }: rustPlatform.buildRustPackage rec {
  pname = "git-nomad";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "rraval";
    repo = pname;
    rev = version;
    sha256 = "0nvlvifqgs4bh0shya8rwzafqjxrzc9knrkjin9z7gy2pads2gc8";
  };

  cargoHash = "sha256-BxHWZJAdzqtnvqkJ8svZ8cBasv4H4RBgbKvXA8deqIA=";

  meta = with lib; {
    homepage = "https://github.com/rraval/git-nomad";
    description = "Synchronize work-in-progress git branches in a light weight fashion.";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
