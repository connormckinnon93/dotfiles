#!/bin/zsh
#
# granted - assume AWS roles / SSO sessions. The `assume` command must be
# SOURCED (not run in a subshell) so it can export the temporary AWS_*
# credentials into the current shell; granted ships `assume` as a POSIX script
# plus the `assumego` binary, and this alias wires that up. Sourcing is also
# what makes the starship AWS prompt segment appear. Docs: https://granted.dev/
#
(( $+commands[assumego] )) || return
alias assume="source assume"
