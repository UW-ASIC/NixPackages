{
  description = "UWASIC EDA Tools - Modular Nix packages for analog IC design";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
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

        # Import all package definitions
        packageDefs = import ./packages { inherit pkgs; };

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

        # Formatter for `nix fmt`
        formatter = pkgs.nixpkgs-fmt;
      }
    );
}

