#!/bin/zsh
#
# zoxide - a smarter cd that learns your most-used directories.
# Replaces `cd` (normal cd for real paths, frecency jumps for queries);
# `cdi` opens the interactive picker.
#
(( $+commands[zoxide] )) || return
eval "$(zoxide init zsh --cmd cd)"
