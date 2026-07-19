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
# The installer is pinned to a reviewed Homebrew/install commit and verified
# by sha256 before it runs (that repo tags no releases, so a commit is the
# pin). To bump: pick the new commit (`git ls-remote
# https://github.com/Homebrew/install.git HEAD`), download install.sh at that
# ref, and update both values together. shasum ships with stock macOS.
HOMEBREW_INSTALL_REF="fea42d9aedd20a82bea800a6898dcde19401ab1f"
HOMEBREW_INSTALL_SHA256="99287f194a8b3c9e6b0203a11a5fa54518be57209343e6bb954dec4635796d9d"
if ! type brew >/dev/null 2>&1 \
  && [ ! -x /opt/homebrew/bin/brew ] && [ ! -x /usr/local/bin/brew ]; then
  echo "Installing Homebrew..."
  installer="$(mktemp)"
  curl -fsSL "https://raw.githubusercontent.com/Homebrew/install/${HOMEBREW_INSTALL_REF}/install.sh" \
    -o "$installer"
  if ! echo "${HOMEBREW_INSTALL_SHA256}  ${installer}" | shasum -a 256 -c - >/dev/null 2>&1; then
    echo "Homebrew installer checksum mismatch (expected ${HOMEBREW_INSTALL_SHA256}); aborting." >&2
    rm -f "$installer"
    exit 1
  fi
  NONINTERACTIVE=1 /bin/bash "$installer"
  rm -f "$installer"
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
