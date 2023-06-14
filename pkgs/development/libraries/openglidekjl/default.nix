{ autoconf, automake, fetchFromGitHub, lib, libGL, libGLU, libtool, libX11, mesa , stdenv }:

stdenv.mkDerivation (finalAttrs: {
  pname = "openglidekjl";
  version = "20230610-unstable";

  src = fetchFromGitHub {
    owner = "kjliew";
    repo = "qemu-xtra";
    rev = "71833f4af3a4f73db0bf72c6e5a615b9fb68fa52";
    hash = "sha256-ePnFo7UhYzmir30w2B2rIvF9vlEBCOg+y/uGRO3MLJo=";
  };

  nativeBuildInputs = [ automake autoconf libtool ];
  buildInputs = [ libGL libGLU libX11 mesa ];

  sourceRoot = "source/openglide";
  preConfigure = "bash bootstrap";
  configureFlags = [ "--disable-sdl" ];

  meta = with lib; {
    description = "OpenGLide fork optimized for QEMU (Supports Glide2x & Glide3x)";
    homepage = "https://github.com/kjliew/qemu-xtra";
    license = licenses.lgpl21;
    maintainers = with maintainers; [ hughobrien ];
    platforms = platforms.linux;
  };
})
