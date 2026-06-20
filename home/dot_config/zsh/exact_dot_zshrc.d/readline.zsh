#!/bin/zsh
#
# readline - point readline at its config file (it only reads ~/.inputrc by
# default, so the XDG location needs this env var).
#
export INPUTRC="${XDG_CONFIG_HOME:-$HOME/.config}/readline/inputrc"
