#!/bin/zsh
#
# Default editor (used by git, gh, and other tools that honor $EDITOR).
#
(( $+commands[nvim] )) || return
export EDITOR=nvim
export VISUAL=nvim
