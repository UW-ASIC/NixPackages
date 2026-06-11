{
  pkgs,
  pyspicePackages,
  mkPySpice,
}:
{
  ngspice-shared = import ./ngspice-shared.nix { inherit pkgs; };
  netgen = import ./netgen.nix { inherit pkgs; };
  xschem = import ./xschem.nix { inherit pkgs; };
  klayout = pkgs.klayout;

  # PySpice (pyspice-rs) bundled with ngspice by default.
  # Pick different simulators via: lib.<system>.mkPySpice { simulators = [ ... ]; }
  pyspice = mkPySpice { };

  # Individual SPICE simulators from the PySpice flake
  inherit (pyspicePackages) openvaf vacask xyce;
}
