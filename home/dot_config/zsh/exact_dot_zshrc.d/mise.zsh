#!/bin/zsh
#
# mise - polyglot runtime manager (node, python, ...). `mise activate` keeps the
# right tool versions on PATH and switches them per directory (reading any
# .mise.toml / .tool-versions). Global tools live in ~/.config/mise/config.toml.
# Docs: https://mise.jdx.dev/
#
(( $+commands[mise] )) || return
eval "$(mise activate zsh)"
