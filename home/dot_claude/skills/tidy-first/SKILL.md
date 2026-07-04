---
name: tidy-first
description: >
  Decide whether to restructure code before a behavioral change, and do it as a
  separate, reversible step — never mixing structure and behavior in one commit.
  Use when about to change code that is awkward to work in, when a small cleanup
  would make an imminent edit easier, when you feel the urge to "clean this up
  while I'm here," or when separating a refactor from a feature. Covers the
  standard micro-tidyings and the tidy-first / tidy-after / don't-tidy decision.
---

# Tidy first?

From Kent Beck: a tidying is a small, safe, behavior-preserving restructuring. The
discipline is not "always clean up" — it's knowing *when* a cleanup earns its place,
and *always* keeping it separate from behavior change. Rationale: directive #1 in
`~/.claude/references/engineering-principles.md`.

Two rules do most of the work:

1. **Never mix structural and behavioral change in one commit.** A pure structural
   change ships with tests unchanged and green, so a reviewer verifies it almost
   mechanically and spends real attention on the behavior diff. Mixing them forces the
   reviewer to diff meaning and shape at once — the expensive thing this avoids.
2. **Tidy only when it pays for the imminent change.** Cleanup is an investment; buy it
   when the next edit is about to use it, not on spec.

## When to Use

- You're about to change code that is hard to change *as it stands* — a tangled
  conditional, a badly-named variable, a function doing two things — and tidying it
  first would make the real edit obvious and safe.
- You catch the "while I'm here, let me clean this up" urge (this skill tells you
  whether to, and how to keep it separate).
- You're deciding how to split a refactor from the feature that rides on it.

## When NOT to Use

- The code is already easy to change — just make the change.
- The cleanup is large or risky (reshaping a module, changing a data structure many
  callers touch): that's a design task, not a tidying. Plan it as its own work (use the
  `slicing-prs` skill) rather than smuggling it in.

## The decision: tidy first, tidy after, or not at all

- **Tidy first** when the mess is directly in the path of the change you're about to
  make and cleaning it makes that change smaller and safer. Do the tidying, commit it
  alone, then make the behavior change on top.
- **Tidy after** when you only understood the right structure *by* making the change,
  and reshaping now would delay shipping. Land the behavior change, then a follow-up
  tidy commit.
- **Don't tidy** when the code isn't in your path, or the payoff is speculative. Note
  it and move on — untouched-but-ugly code is not your commit's problem (this is the
  bounded boy-scout rule).

## The micro-tidyings (your default vocabulary)

Small enough to apply with near-zero risk and approve at a glance:

- **Guard clauses** — replace nested `if/else` with early returns for edge cases.
- **Dead code / commented-out code** — delete it; git is the archive.
- **Explaining variable / helper** — name a sub-expression or extract a well-named
  step, *only* when it clarifies (not to hit a line count — see the deep-modules rule).
- **Rename to intent** — make a name say what the thing is for.
- **Normalize symmetry** — make parallel things look parallel; group by cohesion.
- **Reorder** — move a declaration next to its use; put reading order top-down.

## Procedure

1. About to edit? Ask: is the code hard to change *here*? If no, just change it.
2. If yes, pick the smallest tidying that removes the friction. Prefer one from the
   list above.
3. Apply it with **tests unchanged**; run them — still green proves it's structural.
4. Commit the tidying alone, with a message that says it's a refactor.
5. Now make the behavior change on the clean structure, with its own tests, as its own
   commit.
6. Stop when the friction is gone. Resist tidying past what the change needs.

## Anti-patterns

- **The drive-by cleanup inside a feature diff** — the single most common way to make a
  PR unreviewable. Split it out, even after the fact.
- **Tidying to a metric** (function length, file count) rather than to *changeability*.
  A rename that helps is good; extracting three-line fragments to satisfy a rule is the
  smell the deep-modules directive warns against.
- **Calling a redesign a "tidy."** If tests must change or many callers move, it isn't a
  tidying — treat it as design work and plan it.
