{ pkgs }:
{
  ngspice-shared = import ./ngspice-shared.nix { inherit pkgs; };
  netgen = import ./netgen.nix { inherit pkgs; };
  xschem = import ./xschem.nix { inherit pkgs; };
  klayout = pkgs.klayout;
}
