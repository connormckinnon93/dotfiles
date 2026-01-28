#!/bin/sh

# Bootstrap script for dependencies needed before chezmoi processes templates.
# This runs via hooks.read-source-state.pre, so it must be fast and idempotent.

# Skip if not on macOS
[ "$(uname)" != "Darwin" ] && exit 0

# Install Homebrew if needed
if ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew..."

    # Pinned version and checksum for supply chain security
    # To update: fetch new commit SHA from https://github.com/Homebrew/install
    # then compute: curl -fsSL "https://raw.githubusercontent.com/Homebrew/install/<COMMIT>/install.sh" | shasum -a 256
    HOMEBREW_INSTALL_COMMIT="90fa3d5881cedc0d60c4a3cc5babdb867ef42e5a"
    HOMEBREW_INSTALL_SHA256="1c9db64f27d7487ecf74fe3543b96beb1f78039cc92745c3e825a9a7ccefec80"

    INSTALLER_URL="https://raw.githubusercontent.com/Homebrew/install/${HOMEBREW_INSTALL_COMMIT}/install.sh"
    INSTALLER_PATH=$(mktemp)

    curl -fsSL "$INSTALLER_URL" -o "$INSTALLER_PATH"

    # Verify checksum
    ACTUAL_SHA256=$(shasum -a 256 "$INSTALLER_PATH" | cut -d' ' -f1)
    if [ "$ACTUAL_SHA256" != "$HOMEBREW_INSTALL_SHA256" ]; then
        echo "ERROR: Homebrew installer checksum mismatch!"
        echo "Expected: $HOMEBREW_INSTALL_SHA256"
        echo "Actual:   $ACTUAL_SHA256"
        rm -f "$INSTALLER_PATH"
        exit 1
    fi

    echo "Homebrew installer checksum verified."
    /bin/bash "$INSTALLER_PATH"
    rm -f "$INSTALLER_PATH"
fi

# Ensure brew is in PATH for subsequent commands
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install 1Password CLI if needed (required for templates using onepasswordRead)
if ! command -v op >/dev/null 2>&1; then
    echo "Installing 1Password CLI..."
    brew install --cask 1password-cli
fi
