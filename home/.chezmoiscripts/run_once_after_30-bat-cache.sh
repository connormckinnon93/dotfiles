#!/bin/sh
#
# Build bat's cache so it picks up the antidote .zsh_plugins.txt syntax
# definition. Ordered (30-) after externals place the bat binary + syntax file.
#
export PATH="$HOME/.local/bin:$PATH"
command -v bat >/dev/null 2>&1 || exit 0
bat cache --build >/dev/null 2>&1 || true
