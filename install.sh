#!/bin/bash
set -euo pipefail

# AceCloud CLI Installer
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/AceCloudAI/ace-cli-releases/main/install.sh | bash
#   curl -fsSL <url>/install.sh | bash -s -- --version 1.4.2-beta

VERSION="${ACE_VERSION:-1.4.2-beta}"
INSTALL_DIR="${ACE_INSTALL_DIR:-/usr/local/bin}"

# Parse args
while [[ $# -gt 0 ]]; do
  case $1 in
    --version)  VERSION="$2"; shift 2 ;;
    --dir)      INSTALL_DIR="$2"; shift 2 ;;
    *) echo "Unknown option: $1"; exit 1 ;;
  esac
done

# Detect OS and Arch
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case "$OS" in
  linux)  OS="linux" ;;
  darwin) OS="darwin" ;;
  *)      echo "Unsupported OS: $OS"; exit 1 ;;
esac

case "$ARCH" in
  x86_64|amd64)  ARCH="amd64" ;;
  aarch64|arm64)  ARCH="arm64" ;;
  *)              echo "Unsupported architecture: $ARCH"; exit 1 ;;
esac

BINARY="ace-${OS}-${ARCH}"
DOWNLOAD_URL="https://github.com/AceCloudAI/ace-cli-releases/releases/download/v${VERSION}/${BINARY}"

echo "Installing AceCloud CLI v${VERSION} (${OS}/${ARCH})..."
echo "Downloading from ${DOWNLOAD_URL}..."

if [ "$(id -u)" -ne 0 ] && [ "$INSTALL_DIR" = "/usr/local/bin" ]; then
  echo "Note: Installing to /usr/local/bin requires sudo"
  sudo curl -fsSL "${DOWNLOAD_URL}" -o "${INSTALL_DIR}/ace"
  sudo chmod +x "${INSTALL_DIR}/ace"
else
  curl -fsSL "${DOWNLOAD_URL}" -o "${INSTALL_DIR}/ace"
  chmod +x "${INSTALL_DIR}/ace"
fi

echo "Downloaded ${BINARY} to ${INSTALL_DIR}/ace"

# Verify
if "${INSTALL_DIR}/ace" --version > /dev/null 2>&1; then
  echo "Success! $("${INSTALL_DIR}/ace" --version)"
  echo ""
  echo "Get started:"
  echo "  ace auth login-token --token <your-token>"
  echo "  ace instance list"
else
  echo "Warning: ace was installed but could not verify. Check ${INSTALL_DIR}/ace"
fi
