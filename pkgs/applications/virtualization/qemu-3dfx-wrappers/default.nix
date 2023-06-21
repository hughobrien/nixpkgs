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
    rev = "1f28212c5f8c0e8c59b775eb02bef9e313b8f8e2";
    hash = "sha256-HF7iJOKhSS4FOY0O/+JD9z58UiQmabdxWZDVKATAC0Q=";
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
