#!/usr/bin/env bash
# Stop hook — soft nudge when product source was edited after the last test run.
# It NEVER blocks (no decision:block): it prints a user-visible systemMessage and
# exits 0. The judgment ("were these edits worth testing?") is yours; this only
# makes the omission visible. Fires on every Stop, so it must be quiet by default
# — it says nothing unless a source edit is genuinely newer than any test run.
#
# Deterministic, jq only. Reads the session transcript named on stdin.
set -euo pipefail

input="$(cat)"
transcript="$(printf '%s' "$input" | jq -r '.transcript_path // empty')"
[ -n "$transcript" ] && [ -f "$transcript" ] || exit 0

# Walk the transcript's tool calls in order. Warn iff the last edit to a
# product-source file (excluding test/spec files) is more recent than the last
# test-runner command. Source-file and test-command matching are deliberately
# conservative to keep this quiet.
verdict="$(
  jq -s -r '
    def is_src($p):
      ($p | test("\\.(py|js|jsx|ts|tsx|go|rs|java|rb|c|cc|cpp|h|hpp|cs|php|swift|kt|kts|scala|clj|cljs|ex|exs|sh|bash|zsh|sql|vue|svelte)$"))
      and ($p | test("(^|/)(tests?|__tests__|specs?)(/|$)") | not)
      and ($p | test("(_test\\.|_spec\\.|\\.test\\.|\\.spec\\.|(^|/)test_)") | not);
    def is_test_cmd($c):
        ($c | test("(^|[^A-Za-z])(pytest|py\\.test|unittest|tox|nox|jest|vitest|mocha|ava|rspec|bats|ctest|phpunit)([^A-Za-z]|$)"))
      or ($c | test("\\b(go|cargo|dotnet)\\s+(test|nextest)"))
      or ($c | test("\\b(npm|yarn|pnpm)\\s+(run\\s+)?test"))
      or ($c | test("\\bmake\\s+(test|check)\\b"))
      or ($c | test("\\b(rails|mvn|gradle|gradlew|\\./gradlew)\\s+(test|verify)"))
      or ($c | test("(^|/)(bin/test|run_tests)\\b"));
    ( [ .[] | select(.type=="assistant") | .message.content[]?
        | select(.type=="tool_use") ] ) as $t
    | ( [ range(0; ($t|length)) as $i
          | select($t[$i].name | test("^(Edit|Write|MultiEdit|NotebookEdit)$"))
          | select(is_src($t[$i].input.file_path // $t[$i].input.notebook_path // ""))
          | $i ] | last ) as $lastEdit
    | ( [ range(0; ($t|length)) as $i
          | select($t[$i].name == "Bash")
          | select(is_test_cmd($t[$i].input.command // ""))
          | $i ] | last ) as $lastTest
    | if ($lastEdit != null) and ($lastTest == null or $lastEdit > $lastTest)
      then "warn" else "ok" end
  ' "$transcript" 2>/dev/null || echo ok
)"

[ "$verdict" = "warn" ] || exit 0

jq -nc '{systemMessage: ("⚠ tests-not-run: product source was edited after the last test run this session. Run the relevant suite before treating this as done — see the change-discipline rules in ~/.claude/CLAUDE.md.")}'
exit 0
