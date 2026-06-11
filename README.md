# UWASIC EDA Tools

Modular Nix packages for analog IC design.

## Packages

| Package          | Description                                              |
| ---------------- | -------------------------------------------------------- |
| `ngspice-shared` | ngspice with the shared library (`libngspice`)           |
| `netgen`         | LVS netlist comparison                                   |
| `xschem`         | Schematic capture                                        |
| `klayout`        | Layout viewer/editor                                     |
| `pyspice`        | PySpice (pyspice-rs) bundled with ngspice                |
| `openvaf`        | OpenVAF Verilog-A compiler (from the PySpice flake)      |
| `vacask`         | VACASK simulator (from the PySpice flake)                |
| `xyce`           | Xyce parallel (MPI) simulator (from the PySpice flake)   |

```bash
nix build github:UW-ASIC/NixPackages#pyspice
```

### PySpice: choosing simulators

`pyspice` ships with ngspice by default. To pick which simulator(s) get bundled
(at least one is required), use `mkPySpice` from this flake's `lib`:

```nix
{
  inputs.uwasic-eda.url = "github:UW-ASIC/NixPackages";

  # in your outputs, for your system:
  packages.my-pyspice = uwasic-eda.lib.${system}.mkPySpice {
    simulators = [ "ngspice" "xyce" ]; # any of: ngspice, openvaf, vacask, xyce
  };
}
```

An empty `simulators` list or an unknown simulator name fails evaluation.

## Dev shells

| Shell      | Description                                                  |
| ---------- | ------------------------------------------------------------ |
| `schemify` | Schemify development environment (UW-ASIC/Schemify `master`) |

```bash
nix develop github:UW-ASIC/NixPackages#schemify
```

## Testing

```bash
# Test all packages
nix-build test.nix -A all

# Test a specific package
nix-build test.nix -A testResults.magic-vlsi
nix-build test.nix -A testResults.xschem
nix-build test.nix -A testResults.netgen
```

## Pushing this

bash <(curl -L https://nixos.org/nix/install)
nix-env -iA devenv -f https://github.com/NixOS/nixpkgs/tarball/nixpkgs-unstable

#### Add to devenv.nix:

{
cachix.push = "uwasic-eda";
}

## Cache

```bash
cachix use uwasic-eda
nix build github:UW-ASIC/NixPackages#xschem
```
