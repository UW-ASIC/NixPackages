#!/usr/bin/env bash
set -e

# Script to build and push packages to Cachix locally
# Uses AUTH_TOKEN from .env file

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CACHE_NAME="uwasic-eda"

# Load environment variables from .env
if [ -f "$SCRIPT_DIR/.env" ]; then
    echo "📦 Loading environment from .env..."
    export $(grep -v '^#' "$SCRIPT_DIR/.env" | xargs)
else
    echo "❌ Error: .env file not found!"
    echo "Create a .env file with: AUTH_TOKEN=your_cachix_token"
    exit 1
fi

# Check if AUTH_TOKEN is set
if [ -z "$AUTH_TOKEN" ]; then
    echo "❌ Error: AUTH_TOKEN not found in .env file!"
    exit 1
fi

echo "🔐 Authenticating with Cachix..."
echo "$AUTH_TOKEN" | cachix authtoken --stdin

echo "📝 Configuring Cachix cache: $CACHE_NAME"
cachix use "$CACHE_NAME"

# List of packages to build and push
PACKAGES=(
    "ngspice-shared"
    "netgen"
    "xschem"
    "klayout"
    "pyspice"
    "openvaf"
    "vacask"
    "xyce"
)

echo ""
echo "🚀 Building and pushing packages to Cachix..."
echo "=============================================="

for package in "${PACKAGES[@]}"; do
    echo ""
    echo "📦 Building: $package"
    echo "----------------------------------------------"

    # Build the package
    if nix build ".#$package" --print-build-logs; then
        echo "✅ Built: $package"

        # Push to Cachix
        echo "⬆️  Pushing to Cachix..."
        nix build ".#$package" --json |
            jq -r '.[].outputs.out' |
            cachix push "$CACHE_NAME"

        echo "✅ Pushed: $package to $CACHE_NAME"
    else
        echo "❌ Failed to build: $package"
        exit 1
    fi
done

echo ""
echo "=============================================="
echo "🎉 All packages built and pushed successfully!"
echo ""
echo "Users can now use:"
echo "  cachix use $CACHE_NAME"
echo "  nix build github:UW-ASIC/NixPackages#xschem"
echo ""
