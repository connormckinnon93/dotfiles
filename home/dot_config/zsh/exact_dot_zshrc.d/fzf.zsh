#!/bin/zsh
#
# fzf - fuzzy finder: shell keybindings, plus the Catppuccin Mocha palette
# (from catppuccin/fzf), which fzf-tab inherits via use-fzf-default-opts.
#

(( $+commands[fzf] )) || return

# Append so any earlier FZF_DEFAULT_OPTS survive.
export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:+$FZF_DEFAULT_OPTS }\
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#b4befe,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8 \
--color=selected-bg:#45475a \
--color=border:#6c7086,label:#cdd6f4"

# Shell integration: Ctrl-T (insert file path) and Alt-C (cd into directory).
# It also grabs Ctrl-R, but atuin owns history search (atuin.zsh, sourced
# earlier), so hand Ctrl-R straight back to atuin's widgets in every keymap.
source <(fzf --zsh)
if (( $+widgets[atuin-search] )); then
  bindkey -M emacs '^r' atuin-search
  bindkey -M viins '^r' atuin-search-viins
  bindkey -M vicmd '^r' atuin-search-vicmd
fi
