#!/usr/bin/env bash
# PreToolUse / Bash hook — hard-block a small set of unambiguously catastrophic
# commands, pass everything else. Blocking is friction, so this is deliberately
# high-precision: it fires only on clear footguns, and the safer rephrasing it
# forces (scope an rm, download-then-run, push a branch) is exactly what we want.
#
# Not a security boundary: a determined prompt can route around it (see the
# engineering-principles reference). Deterministic, fast, shell + jq only.
#
# Contract: read the PreToolUse JSON on stdin; to block, print a deny decision as
# JSON on stdout and exit 0; to allow, exit 0 with no output.
set -euo pipefail

input="$(cat)"
cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"
[ -n "$cmd" ] || exit 0

deny() {
  jq -nc --arg r "$1" \
    '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
}

# rm -rf against a catastrophic target. We inspect each command segment's own
# first word, so `echo "rm -rf /"`, `grep rm`, and `git rm -rf ./x` do not trip.
# IFS-split on the shell separators ; & | (newlines collapse via the herestring).
IFS=$'\n' read -r -d '' -a segments < <(
  printf '%s' "$cmd" | tr ';&|\n' '\n' && printf '\0'
)
for seg in "${segments[@]}"; do
  s="${seg#"${seg%%[![:space:]]*}"}"   # ltrim
  s="${s#sudo }"                        # ignore a leading sudo
  [[ "$s" =~ ^rm([[:space:]]|$) ]] || continue
  # recursive AND force, in any flag spelling (-rf, -fr, -r -f, --recursive --force)
  has_rf=0
  if printf '%s' "$s" | grep -Eq -- '(^|[[:space:]])-[a-zA-Z]*r[a-zA-Z]*f|(^|[[:space:]])-[a-zA-Z]*f[a-zA-Z]*r'; then
    has_rf=1
  elif printf '%s' "$s" | grep -Eqi -- '(^|[[:space:]])(-[a-zA-Z]*r|--recursive)([[:space:]]|$)' \
    && printf '%s' "$s" | grep -Eqi -- '(^|[[:space:]])(-[a-zA-Z]*f|--force)([[:space:]]|$)'; then
    has_rf=1
  fi
  [ "$has_rf" -eq 1 ] || continue
  # catastrophic target: filesystem root, home, or --no-preserve-root
  if printf '%s' "$s" | grep -Eq -- '--no-preserve-root' \
    || printf '%s' "$s" | grep -Eq -- '(^|[[:space:]])(/|/\*|~|~/|\$\{?HOME\}?)([[:space:]]|$)'; then
    deny "Refusing 'rm' with recursive+force against a root/home target. Scope the path explicitly (e.g. ./build) and retry."
  fi
done

# Network fetch piped straight into a shell — classic supply-chain footgun.
if printf '%s' "$cmd" | grep -Eq -- '(curl|wget)\b.*\|[[:space:]]*(sudo[[:space:]]+)?(sh|bash|zsh)\b'; then
  deny "Refusing to pipe a network download straight into a shell. Download to a file, inspect it, then run it."
fi

# Force-push that explicitly targets a protected branch. Feature-branch force-push
# and --force-with-lease are left alone.
if printf '%s' "$cmd" | grep -Eq -- 'git[[:space:]]+push\b' \
  && printf '%s' "$cmd" | grep -Eq -- '(^|[[:space:]])(--force|-f)([[:space:]]|$)' \
  && printf '%s' "$cmd" | grep -Eqv -- '--force-with-lease' \
  && printf '%s' "$cmd" | grep -Eq -- '\b(main|master)\b'; then
  deny "Refusing a force-push to main/master. Open a PR, or use --force-with-lease on a feature branch."
fi

exit 0
