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

# Only personal machines read 1Password: templates onepasswordRead solely on
# profile=personal (work renders with no 1Password at all — the work boundary
# guarantee; see CLAUDE.md). Detect work from the init-generated config and
# skip everything op-related there. Missing/unreadable config falls through to
# the personal path: op gets installed (harmless) and the account check below
# still requires a readable config to fire.
chezmoi_config="${XDG_CONFIG_HOME:-$HOME/.config}/chezmoi/chezmoi.toml"
if [ -r "$chezmoi_config" ] \
  && grep -Eq '^[[:space:]]*profile[[:space:]]*=[[:space:]]*"work"' "$chezmoi_config"; then
  exit 0
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

# The op *binary* is not enough: on headed shapes the templates onepasswordRead
# (git signing key, AWS SSO) at render time, which needs a signed-in account.
# On a fresh machine that fails as a cryptic `op signin` template error, so
# fail fast here with instructions instead. Headless shapes render without
# 1Password (see .chezmoiignore.tmpl) and skip the check; so do contexts where
# the init config or the op binary is missing — chezmoi's own errors are
# clearer there. CI's op stub answers `op account list` (see ci.yml).
if command -v op >/dev/null 2>&1 && [ -r "$chezmoi_config" ] \
  && grep -Eq '^[[:space:]]*headless[[:space:]]*=[[:space:]]*false' "$chezmoi_config" \
  && ! op account list 2>/dev/null | grep -q .; then
  cat >&2 <<'EOF'
1Password has no signed-in account, so templates that read op:// references
(git signing key, AWS SSO) cannot render on this headed machine. To fix:
  1. brew install --cask 1password    # if the app is not installed yet
  2. open 1Password, sign in, and enable
     Settings -> Developer -> "Integrate with 1Password CLI"
  3. re-run chezmoi
EOF
  exit 1
fi
