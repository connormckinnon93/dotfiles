#!/bin/zsh
#
# Homebrew - load shellenv (HOMEBREW_PREFIX, MANPATH, INFOPATH, PATH, etc.).
# .zshenv already puts brew on PATH; this sets the rest of the environment.
#
(( $+commands[brew] )) || return
eval "$(brew shellenv)"
