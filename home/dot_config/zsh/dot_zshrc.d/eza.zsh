#!/bin/zsh
#
# eza - a modern ls (installed via Homebrew; no upstream macOS binary).
#
(( $+commands[eza] )) || return
alias ls='eza --icons=auto --group-directories-first'
alias ll='eza -l --icons=auto --git --group-directories-first'
alias la='eza -la --icons=auto --git --group-directories-first'
alias lt='eza --tree --level=2 --icons=auto --group-directories-first'
