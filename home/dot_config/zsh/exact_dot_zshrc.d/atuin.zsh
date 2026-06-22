#!/bin/zsh
#
# atuin - SQLite shell history with fuzzy, context-aware search.
# Binds Up arrow and Ctrl-R. Config in ~/.config/atuin/config.toml (local-only).
#
(( $+commands[atuin] )) || return
eval "$(atuin init zsh)"
