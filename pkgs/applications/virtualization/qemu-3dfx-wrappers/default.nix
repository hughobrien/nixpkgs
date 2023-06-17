{ djgpp_i686, fetchFromGitHub, gendef, git, lib, open-watcom-bin, perl
, pkgsCross, stdenv, unixtools, which }:
let
  mingw32 = (import <nixpkgs> { }).pkgsCross.mingw32;
in stdenv.mkDerivation (finalAttrs: {
  pname = "qemu-3dfx-wrappers";
  version = "unstable_2023-05-29";

  src = fetchFromGitHub {
    owner = "kjliew";
    repo = "qemu-3dfx";
    rev = "f4db048c5c2f19098774bab449ad40c0a3364847";
    hash = "sha256-zNJAf13VuSzzdq4uUrJ63Kl38yrIzN+plFqPy4fBLXo=";
  };

  patchPhase = ''
    runHook prePatch
    for f in wrappers/*/*/Makefile*; do
        substituteInPlace "$f" --replace 'git rev-parse HEAD' 'echo ${finalAttrs.src.rev}'
    done
    substituteInPlace wrappers/3dfx/ovl/Makefile --replace '/opt/watcom11/bin' "$(dirname $(which wcc386))"
    substituteInPlace wrappers/3dfx/ovl/{Makefile,glideovl.lnk} --replace 'obj' 'o'
    substituteInPlace wrappers/3dfx/dxe/glidedxe.c --replace 'uint8_t pad[ALIGNED(1)];' 'uint8_t pad[ALIGNED(1)] = {0};'
    sed -i -e '/^\(QEMU_SRC_DIR\|INCLUDES\)=/s/\\/\//g' wrappers/3dfx/ovl/Makefile
    runHook postPatch
  '';

  buildInputs = [
    djgpp_i686
    gendef
    git
    mingw32.buildPackages.gcc
    open-watcom-bin
    perl
    unixtools.xxd
    which
  ];

  buildPhase = ''
    for d in 3dfx mesa; do
      mkdir wrappers/$d/build; pushd wrappers/$d/build
      bash ../../../scripts/conf_wrapper
      make
      make clean
      popd
    done
  '';

  installPhase = ''
    mkdir -p $out/share
    for d in 3dfx mesa; do
      cp -r wrappers/$d/build $out/share/$d
    done
  '';

  # these files are for windows use so don't mess with them
  dontFixup = true;

  meta = with lib; {
    description = "QEMU MESA GL/3Dfx Glide Pass-Through";
    homepage = "https://github.com/kjliew/qemu-3dfx";
    license = licenses.gpl2;
    maintainers = with maintainers; [ hughobrien ];
    platforms = with platforms; linux ++ windows;
  };
})
