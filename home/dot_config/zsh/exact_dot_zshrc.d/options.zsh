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

# vi-style line editing, matching inputrc's readline setting. starship's
# vimcmd_* symbols show the current mode; atuin binds its own viins/vicmd keys.
# Must precede the bindkey calls below, which then land in the viins keymap.
bindkey -v
# Near-instant ESC (the 400ms default waits for multi-key sequences and makes
# mode switches feel laggy; terminals send escape sequences atomically anyway).
KEYTIMEOUT=1

# Ctrl+Backspace deletes a whole word.
bindkey '^H' backward-kill-word
