{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/nixos-unstable.tar.gz") {
    overlays = [
      (final: prev: {
        # Overlay to fix GCC 15 compatibility issues in criterion
        # This fixes SIZE_MAX not being declared in include/criterion/alloc.h
        criterion = prev.criterion.overrideAttrs (old: {
          postPatch = (old.postPatch or "") + ''
            if [ -f include/criterion/alloc.h ]; then
              sed -i '38a #include <cstdint>' include/criterion/alloc.h
            fi
          '';
        });
      })
    ];
    config = {
      allowUnfree = true;
    };
  }
}:

pkgs.mkShell {
  name = "uwasic-eda-shell";

  packages = [
    pkgs.openroad
    pkgs.magic-vlsi
  ];

  shellHook = ''
    echo "🔧 UWASIC EDA Environment Loaded"
    echo "   - OpenROAD $(openroad -version 2>/dev/null || echo 'present')"
    echo "   - Magic VLSI $(magic --version 2>/dev/null || echo 'present')"
  '';
}
