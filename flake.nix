{
  description = "UWASIC EDA Tools with GCC 15 compatibility patches";
  
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  
  outputs = { self, nixpkgs, flake-utils }:
    let
      # Overlay to fix GCC 15 compatibility issues
      gcc15CompatOverlay = final: prev: {
        # Fix criterion for GCC 15 (missing <cstdint>)
        criterion = prev.criterion.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            # Add #include <stdint.h> for SIZE_MAX declaration (C compatible)
            if [ -f include/criterion/alloc.h ]; then
              sed -i '38a #include <stdint.h>' include/criterion/alloc.h
            fi
          '';
        });
        
        # Fix magic-vlsi for GCC 15 (implicit function declarations and strict prototypes)
        magic-vlsi = prev.magic-vlsi.overrideAttrs (old: {
          env = (old.env or {}) // {
            # Combine existing flags with GCC 15 compatibility flags
            NIX_CFLAGS_COMPILE = toString [
              (old.env.NIX_CFLAGS_COMPILE or "")
              "-Wno-implicit-function-declaration"
              "-Wno-strict-prototypes"
              "-std=gnu11"  # Use C11 instead of C89 for better compatibility
            ];
          };
          
          # Additional configure flags to disable errors
          configureFlags = (old.configureFlags or []) ++ [
            "--disable-werror"
          ];
        });
        
        # Use GCC 14 for OpenROAD to avoid GCC 15 regressions
        openroad = (prev.openroad.override {
          stdenv = prev.gcc14Stdenv;
        }).overrideAttrs (old: {
          # Keep any necessary env overrides, but GCC 14 should be safer
          env = (old.env or {}) // {
            NIX_CFLAGS_COMPILE = toString [
              (old.env.NIX_CFLAGS_COMPILE or "")
              "-Wno-error=implicit-function-declaration"
            ];
          };
        });
      };
    in
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ gcc15CompatOverlay ];
          config = {
            allowUnfree = true;
          };
        };
        
        # EDA packages to build and cache
        edaPackages = {
          inherit (pkgs)
            openroad
            magic-vlsi;
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
            echo "Available tools: openroad, magic"
            echo ""
            echo "📦 Cached packages available from: ${pkgs.lib.optionalString (builtins.getEnv "CACHIX_CACHE" != "") "cachix use uwasic-eda"}"
          '';
        };
        
        # Apps for easy running
        apps = {
          openroad = flake-utils.lib.mkApp { drv = pkgs.openroad; };
          magic = flake-utils.lib.mkApp { drv = pkgs.magic-vlsi; exePath = "/bin/magic"; };
        };
      }
    ) // {
      # Export the overlay for use in other flakes
      overlays.default = gcc15CompatOverlay;
    };
}