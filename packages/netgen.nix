{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "netgen";
  version = "1.5.305";

  src = pkgs.fetchurl {
    url = "http://opencircuitdesign.com/netgen/archive/netgen-${version}.tgz";
    sha256 = "sha256-U9m/pIydfRSlsEWhLDDFsC8+C0Fn3DgYQrwVDETn4Zg=";
  };

  nativeBuildInputs = [ pkgs.python312 ];

  buildInputs = with pkgs; [
    tcl
    tk
    xorg.libX11
  ];

  enableParallelBuilding = true;

  configureFlags = [
    "--with-tcl=${pkgs.tcl}"
    "--with-tk=${pkgs.tk}"
  ];

  NIX_CFLAGS_COMPILE = "-O2";

  postPatch = ''
    find . -name "*.sh" -exec patchShebangs {} \; || true
  '';

  meta = with pkgs.lib; {
    description = "LVS netlist comparison tool";
    homepage = "http://opencircuitdesign.com/netgen/";
    license = licenses.mit;
    maintainers = with maintainers; [ thoughtpolice ];
    platforms = platforms.unix;
  };
}
