# Test all packages

nix-build test.nix -A all

# Test a specific package

nix-build test.nix -A testResults.magic-vlsi
nix-build test.nix -A testResults.xschem
nix-build test.nix -A testResults.netgen
