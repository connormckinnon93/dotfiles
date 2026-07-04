---
name: slicing-prs
description: >
  Decompose a large task into a sequence of independently shippable,
  independently reviewable pull requests, each landing safely on its own. Use
  when a change would touch many files or span multiple concerns, when a diff is
  growing past what one person can review in a sitting, when planning a migration
  or refactor, or whenever you catch yourself about to open one big PR. Not for
  a change that is already small and single-purpose.
---

# Slicing PRs

A big diff is not a big achievement — it's a review you won't get. The scarce resource
is human review attention, and a diff larger than one sitting either gets rubber-
stamped or stalls. Slice the work so each PR is small, self-justifying, and safe to
merge alone. Rationale: directives #1 and #6 in
`~/.claude/references/engineering-principles.md`.

## When to Use

- A task will touch many files or several distinct concerns.
- A working diff is already growing past ~a few hundred meaningful lines, or past what
  you'd want to review at once.
- Planning a migration, a rename across the codebase, or a refactor-then-feature.
- You notice yourself heading toward one large PR — stop and slice first.

## When NOT to Use

- The change is already small and single-purpose. Don't manufacture ceremony.
- An atomic change that genuinely cannot be split without leaving `main` broken (rare —
  usually the split exists and you haven't found it yet; see the techniques below).

## The test for a good slice

Each PR must be **independently shippable** (main stays green and releasable after it
merges), **independently reviewable** (understandable without reading the other PRs in
the series), and **one concern** (a reviewer can state its purpose in a sentence). If a
slice fails any of these, cut differently.

## Procedure

1. **Separate structural from behavioral up front.** This is the highest-leverage cut.
   A pure refactor (moves, renames, extractions) that changes no behavior ships as its
   own PR with tests unchanged and green — a reviewer verifies it almost mechanically.
   Behavior changes then land on the clean structure. Never mix the two in one PR.
   (The `tidy-first` skill, if present, covers when to do the structural change at all.)
2. **Find the seams.** Prefer cuts along: one layer or module per PR; add-the-new before
   remove-the-old; the interface/plumbing before the callers that use it; one
   independent case or endpoint at a time.
3. **Order for safety.** Sequence so `main` is releasable after each merge. The usual
   spine: (a) scaffolding/plumbing with no callers, (b) the new capability behind the
   plumbing, (c) migrate callers, (d) delete the old path. A behavior-flipping slice
   goes last, or behind a flag.
4. **Keep the series moving.** Land each slice before building the next on top of it
   (respecting the repo's merge workflow). Avoid a deep stack of interdependent open
   PRs — it recreates the big-diff review problem.
5. **State the series.** Before starting, write the ordered list of PRs, each with its
   one-sentence purpose. If you can't, you don't understand the work yet — that's the
   signal to explore more, not to start typing.

## Techniques for "it can't be split"

- **Expand / contract (parallel change):** add the new form alongside the old, migrate
  callers incrementally, then remove the old form — three or more safe PRs instead of
  one unsafe one.
- **Feature flag / dark launch:** merge inert code that isn't wired up yet, so
  incomplete work lands safely and the switch-on is a tiny, reviewable final PR.
- **Branch by abstraction:** introduce a seam, move callers to it, swap the
  implementation behind it, remove the seam — each step its own PR.

## Anti-patterns

- **Slicing by file type** ("all the tests in one PR, all the code in another"): neither
  half is independently shippable or reviewable. Slice by concern, and keep each change
  with its tests.
- **A stack ten PRs deep** opened all at once: the reviewer is back to one giant diff,
  just spread across tabs. Land as you go.
- **Re-slicing forever instead of shipping.** The goal is reviewable, not perfect; once
  the slices pass the test above, start.
