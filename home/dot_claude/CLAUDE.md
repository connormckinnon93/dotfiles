# Global engineering directives

Loaded every session, all projects. These are the rules where a capable model's
defaults tend to drift — not a style guide (modern Claude handles naming, dead-code
deletion, guard clauses, and formatting reliably without being told). Keyword force
(`MUST`/`SHOULD`/`PREFER`/`NEVER`/`AVOID`/`MAY`) is defined in
`~/.claude/references/glossary.md`. The reasoning, the trade-offs, and the sources
behind each rule live in `~/.claude/references/engineering-principles.md` — read it
when a rule's *why* matters or is contested.

A project's own `CLAUDE.md` and explicit user instructions override anything here.

## Design

- `PREFER` deep modules: a simple interface over substantial implementation. Do
  `NOT` extract a helper unless it removes real duplication or names a genuine
  domain concept. Three-line pass-through functions and one-implementation
  interfaces are a smell, not cleanliness — each hop is another thing a reader (you,
  next session) must load to follow one behavior.
- Domain and business logic `MUST NOT` import I/O, framework, or vendor-SDK modules.
  Dependencies point from volatile detail toward stable policy. `INSTEAD`, put the
  I/O behind a thin adapter the domain calls.
- Keep the repo layout screaming its domain — top-level modules named for business
  concepts. `AVOID` pattern-suffix names like `Manager`, `Helper`, `Util`, `Impl`.
- `DRY` means one authoritative home per piece of *knowledge*, not zero repeated
  characters. `NEVER` merge two pieces of code just because they look alike today;
  `AVOID` letting one business rule live in two places.

## Comments

- Comment the *why* and the contract: invariants, preconditions, units, and links to
  the incident or ticket that explains a non-obvious choice. `NEVER` write a comment
  that narrates *what* the next line does. The load-bearing knowledge — why a retry
  exists, why an order matters — exists nowhere in the code's text; without it a
  later edit will "simplify" it away.

## Error handling

- `NEVER` swallow an exception or default-and-continue past a violated assumption.
  `INSTEAD`, fail loudly at the boundary where the assumption lives. A silent
  fallback converts a loud bug into quiet data corruption that surfaces far away.

## Change discipline

- Keep structural change and behavioral change in `separate commits`. A pure
  refactor `SHOULD` ship with its tests unchanged and green, so a reviewer can verify
  it almost mechanically and spend attention on the behavior diff.
- Slice work into independently shippable, reviewable PRs. If a diff is larger than
  one sitting can review, the slicing was wrong — re-slice before going further.
- Boy-scout rule, bounded: improve only code in files you are `already` touching, and
  land it as its own commit. `NEVER` expand scope to fix unrelated code inside a
  feature diff — it destroys reviewability.
- You own the output. Being unable to explain why a line works is not resolved by
  "the agent wrote it" — `NEVER` merge code you could not explain on request.
