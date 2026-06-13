#!/bin/zsh
#
# fzf - use the terminal's 16 ANSI colors so fzf (and fzf-tab, via
# use-fzf-default-opts) follow the active tinty/base24 theme. Switching schemes
# with `tinty apply` then recolors fzf automatically.
#

export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS }--color=16"
