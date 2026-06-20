#!/bin/zsh
#
# History configuration.
#

HISTFILE="${ZDOTDIR:-$HOME}/.zsh_history"
HISTSIZE=50000
SAVEHIST=50000

setopt APPEND_HISTORY          # append to the history file, don't overwrite
setopt EXTENDED_HISTORY        # record timestamp and duration per entry
setopt HIST_EXPIRE_DUPS_FIRST  # trim duplicates first when HISTSIZE is exceeded
setopt HIST_IGNORE_DUPS        # don't record an immediately-repeated command
setopt HIST_IGNORE_ALL_DUPS    # drop older duplicate when a command repeats
setopt HIST_IGNORE_SPACE       # don't record commands that start with a space
setopt HIST_FIND_NO_DUPS       # don't show duplicates while searching history
setopt HIST_SAVE_NO_DUPS       # don't write duplicates to the history file
setopt HIST_REDUCE_BLANKS      # trim superfluous whitespace before recording
setopt HIST_VERIFY             # show, don't run, the result of history expansion

# Left off intentionally (polarizing): SHARE_HISTORY, INC_APPEND_HISTORY.
