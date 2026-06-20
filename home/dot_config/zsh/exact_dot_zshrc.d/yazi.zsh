#!/bin/zsh
#
# yazi - terminal file manager. The `y` wrapper launches yazi and, on quit,
# cd's the shell to the directory you ended up in (yazi can't change the parent
# shell's cwd on its own). Plain `yazi` still works without the cd-on-exit.
# https://yazi-rs.github.io/docs/quick-start#shell-wrapper
#
(( $+commands[yazi] )) || return

function y() {
  local tmp cwd
  tmp="$(mktemp -t yazi-cwd.XXXXXX)"
  yazi "$@" --cwd-file="$tmp"
  if IFS= read -r -d '' cwd <"$tmp" && [[ -n "$cwd" && "$cwd" != "$PWD" ]]; then
    builtin cd -- "$cwd"
  fi
  rm -f -- "$tmp"
}
