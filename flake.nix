{
  description = "UWASIC EDA Tools with GCC 15 compatibility patches";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # Overlay to fix GCC 15 compatibility issues
        criterionOverlay = final: prev: {
          # Patch criterion to add missing #include <cstdint> for GCC 15 compatibility
          # This fixes SIZE_MAX not being declared in include/criterion/alloc.h
          criterion = prev.criterion.overrideAttrs (old: {
            postPatch = (old.postPatch or "") + ''
              # Add #include <cstdint> after line 38 in alloc.h to fix GCC 15 build
              if [ -f include/criterion/alloc.h ]; then
                sed -i '38a #include <cstdint>' include/criterion/alloc.h
              fi
            '';
          });
        };

        pkgs = import nixpkgs {
          inherit system;
          overlays = [ criterionOverlay ];
          config = {
            allowUnfree = true;
          };
        };

        # EDA packages to build and cache
        edaPackages = {
          inherit (pkgs)
            openroad
            magic-vlsi
            yosys
            verilator
            klayout;
          # cocotb is a Python package
          cocotb = pkgs.python3Packages.cocotb;
        };

      in {
        # Export individual packages
        packages = edaPackages // {
          default = pkgs.symlinkJoin {
            name = "uwasic-eda-tools";
            paths = builtins.attrValues edaPackages;
          };
        };

        # Development shell with all EDA tools
        devShells.default = pkgs.mkShell {
          name = "uwasic-eda-shell";
          
          packages = builtins.attrValues edaPackages ++ [
            pkgs.git
            pkgs.gnumake
          ];

          shellHook = ''
            echo "🔧 UWASIC EDA Tools Environment"
            echo "Available tools: openroad, magic, yosys, cocotb, verilator, klayout"
          '';
        };

        # Apps for easy running
        apps = {
          openroad = flake-utils.lib.mkApp { drv = pkgs.openroad; };
          magic = flake-utils.lib.mkApp { drv = pkgs.magic-vlsi; exePath = "/bin/magic"; };
          yosys = flake-utils.lib.mkApp { drv = pkgs.yosys; };
          klayout = flake-utils.lib.mkApp { drv = pkgs.klayout; };
        };
      }
    ) // {
      # Export the overlay for use in other flakes
      overlays.default = final: prev: {
        criterion = prev.criterion.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            if [ -f include/criterion/alloc.h ]; then
              sed -i '38a #include <cstdint>' include/criterion/alloc.h
            fi
          '';
        });
      };
    };
}
