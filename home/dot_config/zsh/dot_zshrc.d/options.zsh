#!/bin/zsh
#
# General interactive shell options.
#

unsetopt BEEP                 # no terminal bell
setopt AUTO_CD                # `dir` on its own cds into dir
setopt EXTENDED_GLOB          # advanced glob operators (^ # ~)
setopt INTERACTIVE_COMMENTS   # allow # comments at the interactive prompt

# Complete hidden files too. Scoped to completion only (unlike GLOB_DOTS, which
# would make every glob match dotfiles, e.g. a dangerous `rm *`).
_comp_options+=(globdots)

# Don't syntax-highlight pasted text.
zle_highlight=('paste:none')

# Ctrl+Backspace deletes a whole word.
bindkey '^H' backward-kill-word
