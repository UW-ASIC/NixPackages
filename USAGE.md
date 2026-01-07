# UWASIC EDA Tools - Usage Guide

Pre-built EDA binaries with GCC 15 compatibility fixes, hosted on Cachix.

## 🚀 Quick Start (2 minutes)

### For NixOS Users

Add to your `configuration.nix`:

```nix
{
  nix.settings = {
    substituters = [ "https://uwasic-eda.cachix.org" ];
    trusted-public-keys = [ "uwasic-eda.cachix.org-1:3lSSzwAotLn6fFKrz81jx7XnZdTVGduSVymrKjzOKVY=" ];
  };
}
```

Then rebuild: `sudo nixos-rebuild switch`

### For Non-NixOS (Linux/macOS/WSL)

```bash
# 1. Install Nix (skip if already installed)
curl -L https://nixos.org/nix/install | sh

# 2. Enable the cache
nix-env -iA cachix -f https://cachix.org/api/v1/install
cachix use uwasic-eda

# 3. Enter the EDA environment
nix develop github:UWASIC/NixPackage
```

---

## 📦 Available Tools

| Tool | Command | Description |
|------|---------|-------------|
| OpenROAD | `openroad` | RTL-to-GDS flow |
| Magic | `magic` | VLSI layout editor |
| Yosys | `yosys` | Synthesis suite |
| Verilator | `verilator` | Verilog simulator |
| KLayout | `klayout` | Layout viewer/editor |
| Cocotb | `python -m cocotb` | Verification framework |

---

## 💻 Usage Options

### Option 1: Development Shell (Recommended)

Get all tools in one shell:

```bash
nix develop github:UWASIC/NixPackage
```

### Option 2: Run Single Tool

```bash
# Run yosys directly
nix run github:UWASIC/NixPackage#yosys

# Run magic
nix run github:UWASIC/NixPackage#magic

# Run klayout
nix run github:UWASIC/NixPackage#klayout
```

### Option 3: Temporary Shell with One Tool

```bash
nix shell github:UWASIC/NixPackage#openroad
nix shell github:UWASIC/NixPackage#verilator
```

### Option 4: Use with Devenv

Add to your `devenv.nix`:

```nix
{
  cachix.pull = [ "uwasic-eda" ];
}
```

---

## 🔧 Integration Examples

### In Your Project's flake.nix

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    uwasic-eda.url = "github:UWASIC/NixPackage";
  };

  outputs = { nixpkgs, uwasic-eda, ... }: {
    devShells.x86_64-linux.default = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      eda = uwasic-eda.packages.x86_64-linux;
    in pkgs.mkShell {
      packages = [ eda.yosys eda.openroad eda.magic-vlsi ];
    };
  };
}
```

### Legacy shell.nix

```nix
let
  pkgs = import <nixpkgs> {
    overlays = [
      (builtins.getFlake "github:UWASIC/NixPackage").overlays.default
    ];
  };
in pkgs.mkShell {
  packages = with pkgs; [ openroad magic-vlsi yosys verilator klayout ];
}
```

---

## ❓ Troubleshooting

**"building from source instead of downloading"**
- Run `cachix use uwasic-eda` to enable the cache
- Check cache is in `~/.config/nix/nix.conf`

**"hash mismatch"**
- CI may be rebuilding. Wait ~1 hour and retry.

**Need help?**
- Open an issue at [github.com/UWASIC/NixPackage](https://github.com/UWASIC/NixPackage)
