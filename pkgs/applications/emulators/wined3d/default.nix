{ fetchFromGitHub, lib, pkgsCross, stdenv }:
let
  mingw32 = (import <nixpkgs> { }).pkgsCross.mingw32;
in stdenv.mkDerivation (finalAttrs: {
  pname = "wined3dw32";
  version = "8.10";

  src = fetchFromGitHub {
    owner = "wine-mirror";
    repo = "wine";
    rev = "wine-${finalAttrs.version}";
    hash = "sha256-7xidFOy4dEzQ964Ib2QQJFNOcuesqbhgPaChlLHowVc=";
  };

  configureFlags = [ "--without-x" ];

  # Adapted from https://github.com/adolfintel/wined3d4win/blob/master/build32.sh
  preConfigure = ''
    unset CC
    mkdir wine-tools wine-win32
    cd wine-tools
    ../configure --without-x
  '';

#  patchPhase = ''
#    runHook prePatch
#    for f in wrappers/*/*/Makefile*; do
#        substituteInPlace "$f" --replace 'git rev-parse HEAD' 'echo ${finalAttrs.src.rev}'
#    done
#    substituteInPlace wrappers/3dfx/ovl/Makefile --replace '/opt/watcom11/bin' "$(dirname $(which wcc386))"
#    substituteInPlace wrappers/3dfx/ovl/{Makefile,glideovl.lnk} --replace 'obj' 'o'
#    substituteInPlace wrappers/3dfx/dxe/glidedxe.c --replace 'uint8_t pad[ALIGNED(1)];' 'uint8_t pad[ALIGNED(1)] = {0};'
#    sed -i -e '/^\(QEMU_SRC_DIR\|INCLUDES\)=/s/\\/\//g' wrappers/3dfx/ovl/Makefile
#    runHook postPatch
#  '';
#
  buildInputs = [
    mingw32.buildPackages.gcc
  ];
#
#  buildPhase = ''
#    for d in 3dfx mesa; do
#      mkdir wrappers/$d/build; pushd wrappers/$d/build
#      bash ../../../scripts/conf_wrapper
#      make
#      make clean
#      popd
#    done
#  '';
#
#  installPhase = ''
#    mkdir -p $out/share
#    for d in 3dfx mesa; do
#      cp -r wrappers/$d/build $out/share/$d
#    done
#  '';
#
  # these files are for windows use so don't mess with them
  fixupPhase = "";

  meta = with lib; {
    description = "WineD3D is the component of Wine that implements a replacement for Microsoft Direct3D. WineD3D works as a wrapper for Direct3D calls, and relies on OpenGL for the actual rendering job.";
    homepage = "www.winehq.org";
    license = licenses.lgpl21Plus;
    maintainers = with maintainers; [ hughobrien ];
    platforms = with platforms; linux ++ windows;
  };
})
