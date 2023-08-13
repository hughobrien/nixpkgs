{ cmake
, fpattern
, lib
, SDL2
, stdenv

, extraBuildInputs ? [ ]
, extraMeta ? { }
, name
, src
}:

stdenv.mkDerivation (finalAttrs: {
  inherit name src;

  nativeBuildInputs = [ cmake ];
  buildInputs = [ SDL2 ] ++ extraBuildInputs;
  hardeningDisable = [ "format" ];
  cmakeBuildType = "RelWithDebInfo";

  postPatch = ''
    substituteInPlace third_party/fpattern/CMakeLists.txt \
      --replace "FetchContent_Populate" "#FetchContent_Populate" \
      --replace "{fpattern_SOURCE_DIR}" "${fpattern}/include" \
      --replace "$/nix/" "/nix/"
  '';

  installPhase = ''
    runHook preInstall
    install -D ${name} $out/bin/${name}
    runHook postInstall
  '';

  meta = with lib; {
    license = licenses.sustainableUse;
    maintainers = with maintainers; [ hughobrien TheBrainScrambler ];
    platforms = platforms.linux;
  } // extraMeta;
})
