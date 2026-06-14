#!/bin/zsh
#
# Shell aliases - the single home for hand-written zsh aliases. Git/chezmoi
# shortcuts live in ~/.config/zsh-abbr/user-abbreviations instead (they expand
# inline). Tool-replacement aliases are guarded per-tool so the shell still
# works where a tool isn't installed.
#

# eza - a modern ls (installed via Homebrew; no upstream macOS binary).
if (( $+commands[eza] )); then
  alias ls='eza --icons=auto --group-directories-first'
  alias ll='eza -l --icons=auto --git --group-directories-first'
  alias la='eza -la --icons=auto --git --group-directories-first'
  alias lt='eza --tree --level=2 --icons=auto --group-directories-first'
fi
