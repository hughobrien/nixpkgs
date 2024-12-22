{
  lib,
  stdenv,
  fetchurl,
  SDL2,
  glui,
  libGLU,
  libGL,
  buildFHSUserEnv,
}:

let
  bigpemuDrv = stdenv.mkDerivation rec {
    pname = "BigPEmu";
    version = "1.17";

    src = fetchurl {
      url = "https://www.richwhitehouse.com/jaguar/builds/BigPEmu_Linux64_v${
        builtins.replaceStrings [ "." ] [ "" ] version
      }.tar.gz";
      hash = "sha256-R5f3LD5RcGwdwcZqXGaCSFDyHaJrQ1ghS3kqVvBd38A=";
    };

    installPhase = ''
      mkdir -p $out/bin
      tar -xvf $src -C $out/bin --strip-components=1
    '';

    postInstall = ''
      wrapProgram $out/bin/bigpemu \
        --prefix LD_LIBRARY_PATH : ${
          lib.makeLibraryPath [
            SDL2
            glui
            libGLU
            libGL
          ]
        }
    '';

    dontPatchELF = true;

    meta = with lib; {
      description = "Atari Jaguar Emulator (BigPEmu) by Richard Whitehouse";
      homepage = "https://www.richwhitehouse.com/jaguar/index.php";
      license = licenses.unfree;
      maintainers = [ maintainers.tombert ];
      platforms = [ "x86_64-linux" ];
    };
  };

in
buildFHSUserEnv {
  name = "bigpemu";
  targetPkgs = pkgs: [
    SDL2
    glui
    libGLU
    libGL
  ];
  runScript = "${bigpemuDrv}/bin/bigpemu";
}
