# UWASIC EDA Tools Nix Cache

Pre-built Nix binaries for EDA (Electronic Design Automation) tools with GCC 15 compatibility patches.

## 🚀 Quick Start

### Using the Cache

```bash
# 1. Install Cachix (if not already installed)
nix-env -iA cachix -f https://cachix.org/api/v1/install

# 2. Enable the cache
cachix use uwasic-eda

# 3. Enter the development environment
nix develop github:UWASIC/NixPackage
```

### Available Packages

| Package | Description |
|---------|-------------|
| `openroad` | Open-source RTL-to-GDS flow |
| `magic-vlsi` | VLSI layout editor |
| `yosys` | Open-source synthesis suite |
| `cocotb` | Python-based verification framework |
| `verilator` | Verilog/SystemVerilog simulator |
| `klayout` | Layout viewer and editor |

### Using Individual Packages

```bash
# Run a specific tool
nix run github:UWASIC/NixPackage#yosys

# Build a specific package
nix build github:UWASIC/NixPackage#openroad

# Enter a shell with just one tool
nix shell github:UWASIC/NixPackage#magic-vlsi
```

## 🔧 For Maintainers: Setting Up Cachix

### 1. Create a Cachix Account

1. Go to [cachix.org](https://cachix.org) and sign up
2. Create a new cache (e.g., `uwasic-eda`)
3. Choose the appropriate plan (free tier allows 5GB)

### 2. Generate an Auth Token

1. Go to your Cachix settings
2. Navigate to "Auth Tokens"
3. Create a new token with write permissions
4. Copy the token (you won't see it again!)

### 3. Configure GitHub Repository

1. Go to your GitHub repository settings
2. Navigate to **Settings → Secrets and variables → Actions**
3. Click "New repository secret"
4. Name: `CACHIX_AUTH_TOKEN`
5. Value: Paste your Cachix auth token

### 4. Update the Workflow (if needed)

Edit `.github/workflows/build-cache.yml` and change:

```yaml
env:
  CACHIX_CACHE: your-cache-name  # Change this!
```

### 5. Push and Verify

```bash
git add .
git commit -m "Add Cachix configuration"
git push origin main
```

Check the Actions tab in GitHub to see the build progress.

## 📦 Integrating in Your Project

### Option 1: Use as a Flake Input

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    uwasic-eda.url = "github:UWASIC/NixPackage";
  };

  outputs = { self, nixpkgs, uwasic-eda }: {
    devShells.x86_64-linux.default = let
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      eda = uwasic-eda.packages.x86_64-linux;
    in pkgs.mkShell {
      packages = [
        eda.yosys
        eda.openroad
        eda.magic-vlsi
      ];
    };
  };
}
```

### Option 2: Use the Overlay

Apply the GCC 15 fix overlay to your own nixpkgs:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    uwasic-eda.url = "github:UWASIC/NixPackage";
  };

  outputs = { self, nixpkgs, uwasic-eda }: {
    devShells.x86_64-linux.default = let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        overlays = [ uwasic-eda.overlays.default ];
      };
    in pkgs.mkShell {
      packages = [
        pkgs.openroad  # Now with GCC 15 fix applied
        pkgs.magic-vlsi
      ];
    };
  };
}
```

### Option 3: Legacy shell.nix

```nix
let
  # Fetch the flake
  uwasic-eda = builtins.getFlake "github:UWASIC/NixPackage";
  pkgs = import <nixpkgs> {
    overlays = [ uwasic-eda.overlays.default ];
  };
in pkgs.mkShell {
  packages = with pkgs; [
    openroad
    magic-vlsi
    yosys
    cocotb
    verilator
    klayout
  ];
}
```

## 🔍 Troubleshooting

### "Binary not found in cache"

The first build after a nixpkgs update may not be cached yet. Either:
- Wait for the CI workflow to complete
- Build locally: `nix build .#<package>`

### "Permission denied" when pushing to cache

Ensure:
1. `CACHIX_AUTH_TOKEN` is set correctly in GitHub secrets
2. The token has write permissions
3. The cache name matches in the workflow

### Build failures

Check the GitHub Actions logs. Common issues:
- **Disk space**: Large packages like KLayout need significant space
- **Timeout**: Some packages take a long time; consider increasing timeout

### Local development

```bash
# Clone and enter dev shell
git clone https://github.com/UWASIC/NixPackage
cd NixPackage
nix develop

# Test a build locally
nix build .#yosys --print-build-logs
```

## 🛠️ Technical Details

### GCC 15 Fix

The `criterion` library used by OpenROAD and Magic-VLSI is missing `#include <cstdint>` in `include/criterion/alloc.h`, causing `SIZE_MAX` to be undeclared with GCC 15. This flake applies an overlay that patches criterion:

```nix
criterion = prev.criterion.overrideAttrs (old: {
  postPatch = (old.postPatch or "") + ''
    sed -i '38a #include <cstdint>' include/criterion/alloc.h
  '';
});
```

### Cache Statistics

Visit [cachix.org/cache/uwasic-eda](https://app.cachix.org/cache/uwasic-eda) to see:
- Storage usage
- Download statistics  
- Build history

## 📄 License

This configuration is provided under the MIT License. Individual EDA tools have their own licenses.
