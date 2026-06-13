#!/bin/sh
#
# chezmoi read-source-state.pre hook: install Homebrew before chezmoi reads the
# source state, so brew-dependent templates/scripts can rely on it. Idempotent;
# macOS only. May prompt once for your sudo password on a fresh machine.
#
type brew >/dev/null 2>&1 && exit 0
[ -x /opt/homebrew/bin/brew ] && exit 0
[ "$(uname -s)" = "Darwin" ] || exit 0

echo "Installing Homebrew..."
NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
