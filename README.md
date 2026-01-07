# UWASIC EDA Tools Nix Cache

This repository provides pre-built binaries for **OpenROAD** and **Magic VLSI** with GCC 15 compatibility patches (fixing `criterion` build issues).

## Usage

To use these patched packages in your project, import this flake as an overlay in your `shell.nix`.

### Example `shell.nix`

```nix
let
  # Fetch the flake from GitHub
  uwasic-eda = builtins.getFlake "github:UWASIC/NixPackage";
  
  # Import nixpkgs with the overlay applied
  pkgs = import <nixpkgs> {
    overlays = [ uwasic-eda.overlays.default ];
  };
in pkgs.mkShell {
  packages = with pkgs; [
    openroad
    magic-vlsi
  ];
  
  shellHook = ''
    echo "Environment loaded with patched OpenROAD and Magic VLSI"
  '';
}
```

## Setup for Maintainers

To enable the binary cache so that GitHub Actions can push builds:

1.  Create a cache named `uwasic-eda` on [cachix.org](https://cachix.org).
2.  Add your Cachix Auth Token as a repository secret named `CACHIX_AUTH_TOKEN` in this GitHub repository.
