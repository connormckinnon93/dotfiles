#!/usr/bin/env bash
# PreToolUse / Write|Edit hook — soft warn when a credential literal is about to be
# written into a file that is NOT git-ignored (i.e. could be committed). It does
# NOT block: gitleaks at commit time is the hard backstop; this is an earlier,
# cheaper nudge to stop and use a secret reference (op://, env var) instead.
#
# Quiet by default and fast: it scans the written content first and only touches
# git when a credential pattern actually matches. Placeholders and 1Password
# references are ignored. shell + jq + grep only.
set -euo pipefail

input="$(cat)"
content="$(printf '%s' "$input" | jq -r '
  .tool_input.content
  // .tool_input.new_string
  // ([.tool_input.edits[]?.new_string] | join("\n"))
  // empty')"
[ -n "$content" ] || exit 0

# High-confidence credential shapes — unambiguous, always worth a warning.
high='(-----BEGIN[A-Z ]*PRIVATE KEY-----)|(AKIA[0-9A-Z]{16})|(gh[oprsu]_[A-Za-z0-9]{30,})|(AIza[0-9A-Za-z_-]{35})|(xox[baprs]-[A-Za-z0-9-]{10,})'
# Generic "secretish name = long opaque literal" — higher false-positive risk.
generic='([Aa][Pp][Ii][_-]?[Kk][Ee][Yy]|[Ss][Ee][Cc][Rr][Ee][Tt]|[Tt][Oo][Kk][Ee][Nn]|[Pp][Aa][Ss][Ss][Ww]?[Oo]?[Rr]?[Dd]|[Aa][Cc][Cc][Ee][Ss][Ss][_-]?[Kk][Ee][Yy])[[:space:]]*[:=][[:space:]]*['"'"'"][A-Za-z0-9+/_-]{16,}['"'"'"]'

# Placeholders that mean "this isn't a real secret" — checked against the matched
# token itself, so a genuine secret in a file that merely mentions "example"
# elsewhere still warns.
placeholder='example|placeholder|your[_-]|changeme|redacted|dummy|xxxx|<[a-z_-]+>'

token="$(printf '%s' "$content" | grep -Eom1 -- "$high" || true)"
if [ -z "$token" ]; then
  token="$(printf '%s' "$content" | grep -Eom1 -- "$generic" || true)"
fi
[ -n "$token" ] || exit 0
# Suppress documented examples, placeholders, and secret-manager references.
if printf '%s' "$token" | grep -Eqi -- "$placeholder" \
  || printf '%s' "$token" | grep -Eq -- 'op://|vault:|\$\{?[A-Z_]+\}?'; then
  exit 0
fi

# Only warn if the target file is committable (not git-ignored). If we cannot tell
# (no path, not a repo), warn anyway — a credential literal on disk is worth a look.
path="$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty')"
cwd="$(printf '%s' "$input" | jq -r '.cwd // empty')"
if [ -n "$path" ] && [ -n "$cwd" ]; then
  if git -C "$cwd" check-ignore -q -- "$path" 2>/dev/null; then
    exit 0   # git-ignored (e.g. a .env) — fine, stay silent
  fi
fi

msg="⚠ secret-write-guard: this write looks like a hardcoded credential in a file that is not git-ignored. Use a reference instead (op:// / an env var), or confirm it is a non-secret. gitleaks will hard-block a real secret at commit time."
jq -nc --arg m "$msg" \
  '{hookSpecificOutput:{hookEventName:"PreToolUse",additionalContext:$m},systemMessage:$m}'
exit 0
