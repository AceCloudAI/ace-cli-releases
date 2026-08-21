#!/bin/bash
set -euo pipefail

# AceCloud CLI Installer
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/AceCloudAI/ace-cli-releases/main/install.sh | bash
#
# Installs the latest release by default. To pin a specific version:
#   curl -fsSL <url>/install.sh | bash -s -- --version v1.5.0
#   ACE_VERSION=v1.5.0 curl -fsSL <url>/install.sh | bash

REPO="AceCloudAI/ace-cli-releases"
VERSION="${ACE_VERSION:-}"
INSTALL_DIR="${ACE_INSTALL_DIR:-/usr/local/bin}"

info() { echo "$*"; }
err()  { echo "Error: $*" >&2; exit 1; }

# Parse args
while [[ $# -gt 0 ]]; do
  case $1 in
    --version)  VERSION="$2"; shift 2 ;;
    --dir)      INSTALL_DIR="$2"; shift 2 ;;
    *) err "unknown option: $1" ;;
  esac
done

# Detect OS and Arch
OS="$(uname -s | tr '[:upper:]' '[:lower:]')"
ARCH="$(uname -m)"

case "$OS" in
  linux)  OS="linux" ;;
  darwin) OS="darwin" ;;
  *)      err "unsupported OS: $OS" ;;
esac

case "$ARCH" in
  x86_64|amd64)  ARCH="amd64" ;;
  aarch64|arm64) ARCH="arm64" ;;
  *)             err "unsupported architecture: $ARCH" ;;
esac

# Resolve the version. Defaulting to whatever is marked "latest" means this
# script no longer goes stale every time a release is cut.
if [ -z "$VERSION" ]; then
  info "Looking up latest release..."
  VERSION="$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
    | grep -m1 '"tag_name"' | cut -d'"' -f4)"
  [ -n "$VERSION" ] || err "could not determine latest release tag"
fi

# Accept both "1.5.0" and "v1.5.0"; release tags carry the v prefix.
case "$VERSION" in
  v*) TAG="$VERSION" ;;
  *)  TAG="v$VERSION" ;;
esac

ASSET="ace-${OS}-${ARCH}"
BASE_URL="https://github.com/${REPO}/releases/download/${TAG}"

info "Installing AceCloud CLI ${TAG} (${OS}/${ARCH})..."

# Download to a temp dir first so a failed download or a checksum mismatch never
# leaves a half-written binary at the install path.
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

info "Downloading ${ASSET}..."
curl -fsSL -o "${TMP}/ace" "${BASE_URL}/${ASSET}" \
  || err "download failed — is there a ${OS}/${ARCH} build in ${TAG}?"

# Verify the checksum when the release publishes one.
if curl -fsSL -o "${TMP}/checksums.txt" "${BASE_URL}/checksums.txt" 2>/dev/null; then
  info "Verifying checksum..."
  expected="$(grep " ${ASSET}\$" "${TMP}/checksums.txt" | awk '{print $1}')"
  if [ -n "$expected" ]; then
    if command -v sha256sum >/dev/null 2>&1; then
      actual="$(sha256sum "${TMP}/ace" | awk '{print $1}')"
    else
      actual="$(shasum -a 256 "${TMP}/ace" | awk '{print $1}')"
    fi
    [ "$expected" = "$actual" ] || err "checksum mismatch — aborting"
    info "Checksum verified."
  else
    info "No entry for ${ASSET} in checksums.txt — skipping verification."
  fi
else
  info "No checksums.txt in ${TAG} — skipping verification."
fi

chmod +x "${TMP}/ace"

# Install
if [ ! -w "$INSTALL_DIR" ] && [ "$(id -u)" -ne 0 ]; then
  info "Note: ${INSTALL_DIR} is not writable, using sudo"
  sudo install -m 0755 "${TMP}/ace" "${INSTALL_DIR}/ace"
else
  install -m 0755 "${TMP}/ace" "${INSTALL_DIR}/ace"
fi

info "Installed to ${INSTALL_DIR}/ace"

# Warn if a different ace shadows the one we just installed. Without this the
# user runs an old binary and cannot work out why the new commands are missing.
RESOLVED="$(command -v ace 2>/dev/null || true)"
if [ -n "$RESOLVED" ] && [ "$RESOLVED" != "${INSTALL_DIR}/ace" ]; then
  echo
  echo "Warning: 'ace' on your PATH resolves to ${RESOLVED}, not ${INSTALL_DIR}/ace."
  echo "         Remove the older copy or reorder your PATH."
fi

# Verify
if "${INSTALL_DIR}/ace" --version > /dev/null 2>&1; then
  echo "Success! $("${INSTALL_DIR}/ace" --version)"
  echo ""
  echo "Get started:"
  echo "  ace auth login --email <your-email>"
  echo "  ace instance list"
else
  err "ace was installed to ${INSTALL_DIR}/ace but could not be run"
fi
