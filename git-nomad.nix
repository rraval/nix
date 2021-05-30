{ lib, rustPlatform, fetchFromGitHub }: rustPlatform.buildRustPackage rec {
  pname = "git-nomad";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "rraval";
    repo = pname;
    rev = version;
    sha256 = "1za1zmkp9l1b4sqb68igpg8x93kc9nbg3lkq49x798xy4y83v693";
  };

  cargoHash = "sha256-CoYYlx7RgJ9FkzqBFQou8wXy5rVLXhRbxwYcL/uWia8=";

  meta = with lib; {
    homepage = "https://github.com/rraval/git-nomad";
    description = "Synchronize work-in-progress git branches in a light weight fashion.";
    license = licenses.mit;
    platforms = platforms.all;
  };
}
