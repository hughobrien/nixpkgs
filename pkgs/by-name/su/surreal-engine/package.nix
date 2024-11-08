{
  alsa-lib,
  cmake,
  dbus,
  fetchFromGitHub,
  lib,
  libffi,
  makeWrapper,
  openal,
  pkg-config,
  SDL2,
  stdenv,
  vulkan-loader,
  wayland,
  waylandpp,
  libxkbcommon,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "surreal-engine";
  version = "0-unstable-2024-11-04";

  src = fetchFromGitHub {
    owner = "dpjudas";
    repo = "SurrealEngine";
    rev = "7c16d0973307f501fe6765300bfff354d881a7b7";
    hash = "sha256-W2ePjNBmGNMGN14Q2M/KSFzqTR3YQLX8ycyR3Ms8Ekw=";
  };

  nativeBuildInputs = [
    cmake
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    alsa-lib
    dbus
    libffi
    openal
    SDL2
    vulkan-loader
    wayland
    waylandpp
    libxkbcommon
  ];

  postPatch = ''
    substituteInPlace SurrealEngine/UI/WidgetResourceData.cpp --replace-fail /usr/share $out/share
  '';

  installPhase = ''
    runHook preInstall

    install -Dt $out/bin Surreal{Debugger,Editor,Engine}
    install -Dt $out/share/surrealengine SurrealEngine.pk3

    runHook postInstall
  '';

  postFixup = ''
    for bin in $out/bin/Surreal{Debugger,Editor,Engine}; do
      wrapProgram $bin --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ vulkan-loader ]}
    done
  '';

  meta = with lib; {
    description = "Reimplementation of the original Unreal Engine";
    mainProgram = "SurrealEngine";
    homepage = "https://github.com/dpjudas/SurrealEngine";
    license = licenses.zlib;
    maintainers = with maintainers; [ hughobrien ];
    platforms = platforms.linux;
  };
})
