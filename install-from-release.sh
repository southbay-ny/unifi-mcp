#!/bin/bash
# Script to download and install UniFi Network MCP from GitHub releases

set -e

REPO="ryanbehan/unifi-network-mcp"
TAG="${1:-latest}"
INSTALL_DIR="${2:-$HOME/.local/share/unifi-network-mcp}"

echo "Installing UniFi Network MCP from GitHub release..."
echo "Repository: $REPO"
echo "Tag: $TAG"
echo "Install directory: $INSTALL_DIR"

# Create install directory
mkdir -p "$INSTALL_DIR"
cd "$INSTALL_DIR"

# Download the tarball
echo "Downloading release tarball..."
if [ "$TAG" = "latest" ]; then
    # For latest, we need to get the actual latest release tag
    LATEST_TAG=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    DOWNLOAD_URL="https://github.com/$REPO/releases/download/$LATEST_TAG/unifi-network-mcp-$LATEST_TAG.tar.gz"
else
    DOWNLOAD_URL="https://github.com/$REPO/releases/download/$TAG/unifi-network-mcp-$TAG.tar.gz"
fi

echo "Download URL: $DOWNLOAD_URL"
curl -L "$DOWNLOAD_URL" | tar -xz

echo "Installation complete!"
echo "MCP installed to: $INSTALL_DIR"
echo ""
echo "Next steps:"
echo "1. Copy .env.example to .env and configure your UNIFI_TARGETS"
echo "2. Run: $INSTALL_DIR/run-mcp.sh"
