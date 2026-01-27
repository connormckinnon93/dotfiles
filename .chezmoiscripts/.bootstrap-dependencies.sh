#!/bin/sh

# Bootstrap script for dependencies needed before chezmoi processes templates.
# This runs via hooks.read-source-state.pre, so it must be fast and idempotent.

# Skip if not on macOS
[ "$(uname)" != "Darwin" ] && exit 0

# Install Homebrew if needed
if ! command -v brew >/dev/null 2>&1; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Ensure brew is in PATH for subsequent commands
eval "$(/opt/homebrew/bin/brew shellenv)"

# Install 1Password CLI if needed (required for templates using onepasswordRead)
if ! command -v op >/dev/null 2>&1; then
    echo "Installing 1Password CLI..."
    brew install --cask 1password-cli
fi
