{ cmake
, fpattern
, lib
, makeWrapper
, SDL2
, stdenv

, extraBuildInputs ? [ ]
, extraMeta
, name
, src
}:

stdenv.mkDerivation (finalAttrs: {
  inherit name src;

  nativeBuildInputs = [ cmake makeWrapper ];
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
    install -D ${./wrapper.sh} $out/bin/wrapper.sh
    wrapProgram $out/bin/${name} --run $out/bin/wrapper.sh
    runHook postInstall
  '';

  meta = with lib; {
    license = licenses.sustainableUse;
    maintainers = with maintainers; [ hughobrien TheBrainScrambler ];
    platforms = platforms.linux;
  } // extraMeta;
})
