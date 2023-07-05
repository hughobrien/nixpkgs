{ cmake
, fpattern
, lib
, SDL2
, stdenv
, fetchFromGitHub
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "fallout-ce";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "alexbatalov";
    repo = "fallout1-ce";
    rev = "v${finalAttrs.version}";
    hash = "sha256-EvRkOlvtiVao63S0WRKKuHlhfkdTgc0m6GTyv4EfJFU=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ SDL2 ];
  hardeningDisable = [ "format" ];
  cmakeBuildType = "RelWithDebInfo";

  postPatch = ''
    substituteInPlace third_party/fpattern/CMakeLists.txt --replace "FetchContent_Populate" "#FetchContent_Populate"
    substituteInPlace third_party/fpattern/CMakeLists.txt --replace "{fpattern_SOURCE_DIR}" "${fpattern}/include"
    substituteInPlace third_party/fpattern/CMakeLists.txt --replace "$/nix/" "/nix/"
  '';

  installPhase = ''
    runHook preInstall
    install -D fallout-ce $out/bin/fallout-ce
    runHook postInstall
  '';

  meta = with lib; {
    description = "A fully working re-implementation of Fallout, with the same original gameplay, engine bugfixes, and some quality of life improvements.";
    homepage = "https://github.com/alexbatalov/fallout1-ce";
    license = licenses.sustainableUse;
    maintainers = with maintainers; [ hughobrien ];
    platforms = platforms.linux;
  };
})
