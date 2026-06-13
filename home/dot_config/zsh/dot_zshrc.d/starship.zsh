#!/bin/zsh
#
# starship - cross-shell prompt.
#
# Installed as a binary via chezmoiexternal. Optional config lives at
# ~/.config/starship.toml; with no file, starship uses its defaults.
# Sourced last (alphabetically) so the prompt is initialized after everything.
#

(( $+commands[starship] )) || return

eval "$(starship init zsh)"
