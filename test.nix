{
  pkgs ? import <nixpkgs> { },
}:

let
  # Import the flake to test
  flake = builtins.getFlake (toString ./.);
  packages = flake.packages.${pkgs.system};

  # Test each package
  testPackage =
    name: pkg:
    pkgs.runCommand "test-${name}" { } ''
      echo "Testing ${name}..."

      # Check that the package exists
      if [ ! -e "${pkg}" ]; then
        echo "ERROR: Package ${name} does not exist!"
        exit 1
      fi

      # Check that it has binaries or libraries
      if [ -d "${pkg}/bin" ]; then
        echo "✓ ${name} has binaries:"
        ls -la "${pkg}/bin" || true
      fi

      if [ -d "${pkg}/lib" ]; then
        echo "✓ ${name} has libraries:"
        ls -la "${pkg}/lib" | head -10 || true
      fi

      # For xschem, check for the xschem binary
      ${pkgs.lib.optionalString (name == "xschem") ''
        if [ ! -f "${pkg}/bin/xschem" ]; then
          echo "ERROR: xschem binary not found!"
          exit 1
        fi
        echo "✓ xschem binary found: ${pkg}/bin/xschem"
      ''}

      # For netgen, check for the netgen binary
      ${pkgs.lib.optionalString (name == "netgen") ''
        if [ ! -f "${pkg}/bin/netgen" ]; then
          echo "ERROR: netgen binary not found!"
          exit 1
        fi
        echo "✓ netgen binary found: ${pkg}/bin/netgen"
      ''}

      # For ngspice-shared, check for shared library
      ${pkgs.lib.optionalString (name == "ngspice-shared") ''
        if [ ! -f "${pkg}/lib/libngspice.so" ] && [ ! -f "${pkg}/lib/libngspice.dylib" ]; then
          echo "ERROR: ngspice shared library not found!"
          exit 1
        fi
        echo "✓ ngspice shared library found"
      ''}

      echo "✅ ${name} passed all tests!"
      touch $out
    '';

  # Test results for each package
  testResults = pkgs.lib.mapAttrs testPackage packages;

  # Summary test that combines all results
  allTests =
    pkgs.runCommand "test-all-packages"
      {
        buildInputs = builtins.attrValues testResults;
      }
      ''
              echo "=========================================="
              echo "UWASIC EDA Packages - Test Summary"
              echo "=========================================="
              echo ""
              
              echo "Testing ${toString (builtins.length (builtins.attrNames packages))} packages:"
              ${pkgs.lib.concatStringsSep "\n" (
                pkgs.lib.mapAttrsToList (name: pkg: ''
                  echo "  ✓ ${name}"
                '') packages
              )}
              
              echo ""
              echo "=========================================="
              echo "✅ All packages built successfully!"
              echo "=========================================="
              
              # Create output
              mkdir -p $out
              cat > $out/test-results.txt << EOF
        UWASIC EDA Packages Test Results
        =================================

        Tested packages:
        ${pkgs.lib.concatStringsSep "\n" (
          pkgs.lib.mapAttrsToList (name: pkg: "  - ${name}: ${pkg}") packages
        )}

        All tests passed!
        EOF
              
              echo ""
              echo "Test results written to: $out/test-results.txt"
      '';

in
{
  # Individual test results
  inherit testResults;

  # Combined test
  all = allTests;

  # Helper to run individual package tests
  # Usage: nix-build test.nix -A testResults.xschem
}
