let
  # Fetch the flake from the local directory
  uwasic-eda = builtins.getFlake (toString ./.);
  
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
