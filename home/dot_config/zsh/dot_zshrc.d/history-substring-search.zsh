#!/bin/zsh
#
# zsh-history-substring-search keybindings.
#
# The plugin only provides the widgets; binding keys is left to the user, and
# must happen after the plugin loads (which .zshrc.d guarantees, being sourced
# after `antidote load`).
#

# Return matches newest-first without duplicates.
HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

# Up/Down: prefer terminfo, fall back to common raw escape sequences.
[[ -n ${terminfo[kcuu1]} ]] && bindkey "${terminfo[kcuu1]}" history-substring-search-up
[[ -n ${terminfo[kcud1]} ]] && bindkey "${terminfo[kcud1]}" history-substring-search-down
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Ctrl-P / Ctrl-N as well.
bindkey '^P' history-substring-search-up
bindkey '^N' history-substring-search-down
