{ lib, rustPlatform, fetchFromGitHub }: rustPlatform.buildRustPackage rec {
  pname = "git-nomad";
  version = "e71a24a70e188b58c3437493e094bb2653a1e405";

  src = fetchFromGitHub {
    owner = "rraval";
    repo = pname;
    rev = version;
    sha256 = "181la85f4n94xzz6fbh50hnqrfawc5iwr6ac2wwdwxgrak89rhqq";
  };

  cargoHash = "sha256-Hh1pQJyM2/y5OfZwMLeEumKmVBH8DhESJrl3JLKe3/o=";

  meta = with lib; {
    homepage = "https://github.com/rraval/git-nomad";
    description = "Synchronize work-in-progress git branches in a light weight fashion.";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
