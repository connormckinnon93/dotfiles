---
name: tracer-bullet
description: >
  Build a non-trivial feature as a tracer bullet — the thinnest possible
  end-to-end path through every layer it will touch, working and reviewed,
  before fleshing out any single part. Use when starting a feature that spans
  more than one layer or module (UI→API→store, ingest→process→output, a new
  command wired through to real effect), when the integration is the risky part,
  or when you're unsure you've understood the task. Not for one-file changes,
  bug fixes, or work with no cross-layer wiring.
---

# Tracer bullet

Named for a round that glows so you can watch its whole flight and correct aim in
real time. A tracer bullet is a skeleton that runs the *entire* path end to end with
almost nothing in it — real wiring, trivial bodies — so you find out early whether
the pieces connect and whether you understood the task. Rationale: directive #7 in
`~/.claude/references/engineering-principles.md`.

The point is **validation at 5% spend, not 95%.** A feature that looks done in each
part but was never wired together is the expensive failure this prevents.

## When to Use

- A feature crosses layers or modules (request → handler → domain → store → response;
  a new CLI/command that must produce a real effect; a pipeline stage added end to end).
- The integration — not the logic of any one piece — is the uncertain part.
- You are not fully sure you understood the request; a running skeleton is the
  cheapest way to surface a misunderstanding to the reviewer.

## When NOT to Use

- One-file or single-layer changes, bug fixes, refactors — there is no path to trace.
- Work where the wiring is trivial and the risk is entirely in one algorithm; just
  write and test that.
- A spike whose only goal is to learn something throwaway (that's a prototype — you
  intend to keep a tracer bullet).

## Procedure

1. **Name the endpoints.** Write down the entry point (what triggers this) and the
   observable end effect (what a user or caller sees when it works). The tracer bullet
   connects exactly these two.
2. **List the layers between them.** Each real boundary the path crosses is a stop:
   transport, handler, domain, persistence, external call, response/output.
3. **Wire the whole path with trivial bodies.** Hardcode a return, echo a fixed value,
   pass a stub through each layer — but use the *real* interfaces, real function calls,
   real routing. No mocks at the seams you're trying to validate. The skeleton must
   actually execute from entry to end effect.
4. **Run it end to end and watch it fly.** Drive the real entry point and observe the
   real end effect (the `verify` skill, if present, is the right tool). Green here
   means the pieces connect and your mental model holds.
5. **Get it reviewed as its own small change.** This is a natural, tiny first PR — the
   skeleton is where an architecture or requirements mistake is cheapest to fix.
6. **Flesh out one slice at a time.** Replace trivial bodies with real logic, one
   layer or one case per step, each with its own tests. Use the `slicing-prs` skill to
   decide the increments. The path stays green the whole way.

## Anti-patterns

- **Building bottom-up** (finish the database layer, then the domain, then the API):
  you discover integration problems last, when they're most expensive. Trace the path
  first, deepen it after.
- **Stubbing the seam you're trying to prove.** If the risk is "does the handler
  actually reach the store," a mocked store validates nothing. Stub the *bodies*, keep
  the *connections* real.
- **Letting the tracer bullet become the feature.** It is scaffolding with real
  wiring, not a finished thin feature — plan to fill it in, and don't ship the
  hardcoded return as if it were the logic.
