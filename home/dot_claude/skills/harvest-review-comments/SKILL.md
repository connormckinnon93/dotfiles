---
name: harvest-review-comments
description: >
  Turn a recurring review comment into an automated check, so the machine catches
  it next time instead of a human. Use when you notice the same feedback given
  more than once (in PR reviews, from a linter you keep re-explaining, or a
  mistake you keep re-making), when doing a review-process retro, or when a
  reviewer says "I've mentioned this before." Not for one-off or purely
  subjective style notes.
---

# Harvest review comments

A review comment is a bug report against your toolchain. The first time a human flags
something is information; the *second* time is waste — the check should have been
automated after the first. This skill converts repeated human review into a
deterministic gate, freeing scarce review attention for judgment only a human can
give. Rationale: directive #13 in
`~/.claude/references/engineering-principles.md`.

## When to Use

- The same feedback has appeared two or more times — across PRs, reviewers, or your own
  repeated mistakes.
- A review retro, or a moment where you think "we keep hitting this."
- A reviewer explicitly says "I've said this before" / "same as last time."

## When NOT to Use

- A one-off comment with no sign it will recur.
- Genuinely subjective taste that resists a rule (naming *judgment*, architectural
  trade-offs) — automating these produces noisy false positives that train people to
  ignore the tool. Automate the mechanical; leave the judgment to humans.
- Something already covered by an existing check that's merely turned off — just enable
  it.

## Choose the cheapest mechanism that catches it

Prefer the earliest, most deterministic gate that reliably catches the class:

1. **Formatter / existing linter rule** — if a config flag or an off-the-shelf rule
   already covers it, enable it. Cheapest possible.
2. **Custom lint rule** (eslint/ruff/semgrep/etc.) — for a project-specific pattern the
   stock rules miss. This is the sweet spot for most harvested comments.
3. **Pre-commit / git hook** — for fast, offline, whole-file checks (formatting,
   secrets, banned patterns) that should block before a commit exists.
4. **CI check** — for anything slow, needing the network, or needing the full build/test
   environment. The server-side backstop.
5. **A CLAUDE.md rule or a skill** — only when the thing genuinely can't be mechanized
   but must still be remembered. This is the *last* resort: prose is the weakest
   enforcement, and it spends context budget every session.

## Procedure

1. **Name the class, not the instance.** Generalize the comment to the pattern it
   represents ("don't log secrets," "public functions need a docstring"), so the check
   catches the next variant, not just this line.
2. **Pick the lowest mechanism above that reliably catches the class** without a wave of
   false positives. Precision matters more than recall — a noisy check gets disabled.
3. **Write it and prove it fires:** confirm it flags a known-bad example and stays
   silent on known-good ones (the same warn/silent fixture discipline the hooks in
   `~/.claude/hooks/` use).
4. **Wire it into the pipeline** where the rest of that project's checks live, and make
   the failure message say how to fix it, not just that it's wrong.
5. **Retire the human comment.** The point is that nobody has to type it again.

## Anti-patterns

- **Automating taste.** A false-positive-heavy rule is worse than the comment — people
  mute it and lose the real signal too.
- **Reaching for a CLAUDE.md line first.** Prose is the weakest gate; try to mechanize
  before you memorialize. Only durable, un-mechanizable rules earn always-loaded tokens.
- **A check with a cryptic failure.** If the message doesn't tell the next person how to
  fix it, you've replaced a helpful human comment with an unhelpful robot one.
