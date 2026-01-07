# Test all packages

nix-build test.nix -A all

# Test a specific package

nix-build test.nix -A testResults.magic-vlsi
nix-build test.nix -A testResults.xschem
nix-build test.nix -A testResults.netgen

## Pushing this

bash <(curl -L https://nixos.org/nix/install)
nix-env -iA devenv -f https://github.com/NixOS/nixpkgs/tarball/nixpkgs-unstable

#### Add to devenv.nix:

{
cachix.push = "uwasic-eda";
}
