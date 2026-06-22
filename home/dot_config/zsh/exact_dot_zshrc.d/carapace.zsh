#!/bin/zsh
#
# carapace - multi-shell completion engine.
#
# Installed as a binary via chezmoiexternal. Bridged to other completion
# systems so commands carapace doesn't cover fall back to native zsh,
# bash-completion, and fish completions.
#

(( $+commands[carapace] )) || return

export CARAPACE_BRIDGES='zsh,bash,fish'
source <(carapace _carapace zsh)
