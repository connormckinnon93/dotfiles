#!/bin/sh
#
# chezmoi read-source-state.pre hook: install Homebrew and the 1Password CLI
# before chezmoi reads the source state. brew-dependent run_* scripts and the
# templates that call onepasswordRead at read time (git config/allowed_signers,
# aws config) both rely on these being present. Idempotent; macOS only. May
# prompt once for your sudo password on a fresh machine.
#
[ "$(uname -s)" = "Darwin" ] || exit 0

# Install Homebrew if absent (type check covers an already-on-PATH brew; the
# prefix checks cover a brew installed earlier this run but not yet on PATH).
if ! type brew >/dev/null 2>&1 \
  && [ ! -x /opt/homebrew/bin/brew ] && [ ! -x /usr/local/bin/brew ]; then
  echo "Installing Homebrew..."
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 1Password CLI is required by templates using onepasswordRead, which chezmoi
# evaluates at source-state read time — before any run_* script can install it.
# (The 1password-cli cask is also in the brew bundle, but that runs too late.)
if ! command -v op >/dev/null 2>&1; then
  # Ensure the just-installed brew is on PATH for this hook invocation.
  for brew_bin in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [ -x "$brew_bin" ] && eval "$("$brew_bin" shellenv)" && break
  done
  echo "Installing 1Password CLI..."
  brew install --cask 1password-cli
fi
