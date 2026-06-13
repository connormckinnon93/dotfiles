#!/bin/zsh
#
# zsh-autosuggestions configuration.
#
# These are plain parameters (not zstyles), so they live here rather than in
# .zstyles. The plugin defers its real init to the first precmd, which runs
# after .zshrc.d is sourced, so they are in place in time.
#

# Suggest from history first, then fall back to the completion system (carapace).
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

# Enable asynchronous fetching so a large history never blocks typing.
# (The plugin only checks whether this is set, then normalizes the value.)
ZSH_AUTOSUGGEST_USE_ASYNC=1
