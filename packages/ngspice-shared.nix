{ pkgs }:

pkgs.ngspice.override {
  withNgshared = true;
}
