{ callPackage
, fetchFromGitHub
, zlib
}:

callPackage ./build.nix rec {
  name = "fallout2-ce";

  src = fetchFromGitHub {
    owner = "alexbatalov";
    repo = "fallout2-ce";
    rev = "v1.2.0";
    hash = "sha256-+N4jhmxBX6z48kaU0jm90OKhguHlggT3OF9uuyY0EV0=";
  };

  extraBuildInputs = [ zlib ];
  extraMeta = {
    description = "A fully working re-implementation of Fallout 2, with the same original gameplay, engine bugfixes, and some quality of life improvements.";
    homepage = "https://github.com/alexbatalov/fallout2-ce";
  };
}
