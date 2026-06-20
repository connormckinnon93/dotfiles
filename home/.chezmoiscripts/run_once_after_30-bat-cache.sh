#!/bin/sh
#
# Build bat's cache so it picks up the antidote .zsh_plugins.txt syntax
# definition placed by chezmoiexternal. Ordered (30-) after externals land.
# (The Catppuccin Mocha theme is bundled with bat, so it needs no cache step.)
#
export PATH="$HOME/.local/bin:$PATH"
command -v bat >/dev/null 2>&1 || exit 0
bat cache --build >/dev/null 2>&1 || true
