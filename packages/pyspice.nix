{ pkgs, pyspicePackages }:

# Builder for a PySpice (pyspice-rs) environment bundled with one or more
# SPICE simulators. At least one simulator must be selected.
#
#   mkPySpice { }                                          -> pyspice + ngspice (default)
#   mkPySpice { simulators = [ "ngspice" "xyce" ]; }       -> pyspice + ngspice + xyce
#
# Available simulators: ngspice, openvaf, vacask, xyce
{
  simulators ? [ "ngspice" ],
}:

let
  lib = pkgs.lib;

  available = {
    # Use the library's ngspice-shared (bin + libngspice) so it matches the cachix cache
    ngspice = import ./ngspice-shared.nix { inherit pkgs; };
    inherit (pyspicePackages) openvaf vacask xyce;
  };

  availableNames = lib.attrNames available;
  unknown = lib.subtractLists availableNames simulators;
in

assert lib.assertMsg (simulators != [ ])
  "pyspice: at least one simulator must be selected (available: ${lib.concatStringsSep ", " availableNames})";
assert lib.assertMsg (unknown == [ ])
  "pyspice: unknown simulator(s): ${lib.concatStringsSep ", " unknown} (available: ${lib.concatStringsSep ", " availableNames})";

pkgs.symlinkJoin {
  name = "pyspice-with-${lib.concatStringsSep "-" simulators}";
  paths = [ pyspicePackages.default ] ++ map (s: available.${s}) simulators;
}
