{
  description = "UWASIC EDA Tools - Modular Nix packages for analog IC design";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    pyspice = {
      url = "github:OmarSiwy/PySpice";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    schemify = {
      url = "github:UW-ASIC/Schemify/master";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
      inputs.pyspice.follows = "pyspice";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      pyspice,
      schemify,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };

        pyspicePackages = pyspice.packages.${system};

        # Builder for PySpice with a custom simulator selection (at least one).
        # Usage: lib.<system>.mkPySpice { simulators = [ "ngspice" "xyce" ]; }
        mkPySpice = import ./packages/pyspice.nix { inherit pkgs pyspicePackages; };

        # Import all package definitions
        packageDefs = import ./packages { inherit pkgs pyspicePackages mkPySpice; };

      in
      {
        # Export individual packages
        packages = packageDefs // {
          default = pkgs.symlinkJoin {
            name = "uwasic-eda-tools";
            paths = builtins.attrValues packageDefs;
          };
        };

        # Apps for easy running
        apps = {
          xschem = flake-utils.lib.mkApp {
            drv = packageDefs.xschem;
          };
          netgen = flake-utils.lib.mkApp {
            drv = packageDefs.netgen;
          };
        };

        # Dev shells
        devShells = {
          # Schemify development environment (re-exported from UW-ASIC/Schemify master)
          schemify = schemify.devShells.${system}.default;
        };

        # Library functions
        lib = {
          inherit mkPySpice;
        };

        # Formatter for `nix fmt`
        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
