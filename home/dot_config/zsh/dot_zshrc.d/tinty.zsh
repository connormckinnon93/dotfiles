#!/bin/zsh
#
# tinty - base16/base24 theme manager.
#
# Re-applies the current scheme (terminal ANSI palette, etc.) on shell startup,
# so every ANSI-aware tool (fzf, eza, fast-syntax-highlighting, ls) stays in
# sync. Switch themes with `tinty apply <scheme>`; browse with `tinty gallery`.
#

(( $+commands[tinty] )) || return

eval "$(tinty generate-completion zsh)"
tinty init
