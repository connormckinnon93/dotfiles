#!/bin/zsh
#
# ripgrep - point rg at its config file (rg only reads it via this env var).
#
export RIPGREP_CONFIG_PATH="${XDG_CONFIG_HOME:-$HOME/.config}/ripgrep/config"
