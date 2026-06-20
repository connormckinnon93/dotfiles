#!/bin/zsh
#
# Editors. $EDITOR is the terminal editor (git, gh, and other CLI tools honor
# it); $VISUAL is the GUI editor preferred by tools when a display is present.
#
if (( $+commands[nvim] )); then
  export EDITOR=nvim
  # man pages don't honor $EDITOR; route them through nvim's man mode.
  export MANPAGER='nvim +Man!'
fi

# Zed as the GUI editor. macOS exposes the CLI as `zed` (Linux ships `zeditor`).
# `--wait` blocks until the buffer closes so it behaves as a real $VISUAL
# (commit messages, `crontab -e`, ...).
if (( $+commands[zed] )); then
  export VISUAL='zed --wait'
fi
