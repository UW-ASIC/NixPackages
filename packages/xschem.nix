{ pkgs }:

pkgs.stdenv.mkDerivation rec {
  pname = "xschem";
  version = "3.4.7";

  src = pkgs.fetchFromGitHub {
    owner = "StefanSchippers";
    repo = "xschem";
    rev = version;
    sha256 = "sha256-ye97VJQ+2F2UbFLmGrZ8xSK9xFeF+Yies6fJKurPOD0=";
  };

  nativeBuildInputs = [
    pkgs.bison
    pkgs.flex
    pkgs.pkg-config
  ]
  ++ pkgs.lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
    pkgs.fixDarwinDylibNames
  ];

  buildInputs = with pkgs; [
    tcl
    tk
    xorg.libX11
    xorg.libXpm
    cairo
    readline
    flex
    bison
    zlib
  ];

  enableParallelBuilding = true;
  NIX_CFLAGS_COMPILE = "-O2";
  hardeningDisable = [ "format" ];

  meta = with pkgs.lib; {
    description = "Schematic capture and netlisting EDA tool";
    longDescription = ''
      Xschem is a schematic capture program, it allows creation of
      hierarchical representation of circuits with a top down approach.
      By focusing on interfaces, hierarchy and instance properties a
      complex system can be described in terms of simpler building
      blocks. A VHDL or Verilog or Spice netlist can be generated from
      the drawn schematic, allowing the simulation of the circuit.
    '';
    homepage = "https://xschem.sourceforge.io/stefan/";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ fbeffa ];
    platforms = platforms.unix;
  };
}
