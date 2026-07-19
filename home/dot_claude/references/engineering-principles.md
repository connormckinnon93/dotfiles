# Engineering principles (distilled for agent-written code)

A durable reference, loadable on demand. It distills five engineering books for
2026 practice — where an AI agent writes most of the code under human supervision —
and records the structural conventions used to author the skills, agents, and hooks
in this `~/.claude`. The always-loaded `CLAUDE.md` carries only the handful of rules
that fight the model's priors; the reasoning, the discards, and the disagreements
live here so they outlive any single session.

Keyword force (MUST/SHOULD/MAY/…) is defined in [`glossary.md`](glossary.md).

## Framing assumption

In 2026 the scarce resources are **human review attention** and **agent context
budget**. Code is cheap to produce and expensive to verify. Advice that optimizes
*cost to write* is dead; advice that optimizes *cost to read, verify, and safely
change* matters more than when these books were written. Two consequences recur:
indirection is now a tax on the reader (often a model with a token limit), and
anything deterministic should be enforced by a hook, not trusted to prose.

## The directives (actionable core)

Mechanism: **md** = always-loaded `CLAUDE.md` rule · **skill** = on-demand
procedure · **agent** = isolated review lens · **hook** = deterministic enforcement
· **none** = modern Claude already does this reliably; encoding it wastes context.

**Status:** the Mechanism column is a roadmap, not an inventory. Today the only
built artifact is the `block-dangerous-bash` hook; every named skill/agent/hook
below is marked *(planned)* and does not exist yet — don't invoke them.

| # | Directive | Source | Mechanism |
|---|---|---|---|
| 1 | Never mix structural and behavioral change in one commit; a pure refactor ships with tests unchanged and green. | Tidy First | md + skill (`tidy-first`, planned) |
| 2 | Domain/business logic never imports I/O, framework, or vendor SDKs. | Clean Architecture | md (names the rule) + hook where a linter exists |
| 3 | Prefer deep modules; don't extract a helper unless it removes real duplication or names a domain concept. Three-line ceremony functions are a smell. | Ousterhout over Clean Code | md |
| 4 | Comment the *why* and the contract (invariants, preconditions, units, incident/ticket links); never narrate the *what*. | Ousterhout, Pragmatic | md |
| 5 | No silent fallbacks: never swallow exceptions or default-and-continue past a violated assumption; fail loudly at the boundary. | Pragmatic ("crash early"), Clean Code | md |
| 6 | Slice work into independently shippable, human-reviewable PRs; if a diff exceeds one sitting, re-slice. | Accelerate, Tidy First | md + skill (`slicing-prs`, planned) |
| 7 | Start a non-trivial feature as the thinnest end-to-end path, reviewed before flesh-out. | Pragmatic (tracer bullet) | skill (`tracer-bullet`, planned) |
| 8 | Behavior changes ship with tests; run the relevant suite before reporting done. | Clean Code, Accelerate | hook (`tests-not-run`, soft, planned) + md |
| 9 | Bounded boy-scout rule: improve only files already being touched, as a separate commit; never expand scope. | Clean Code ∩ Tidy First | md |
| 10 | DRY = one home per piece of *knowledge*; don't merge coincidentally-similar code, don't duplicate a business rule. | Pragmatic | md + agent (`dry-lens`, planned) |
| 11 | Review substantial changes for dependency direction, boundary erosion, and speculative abstraction (one-impl interfaces, unused extension points). | Clean Architecture ∩ YAGNI | agent (`architecture-review`, planned) |
| 12 | Keep the repo layout screaming the domain; ban `Manager`/`Helper`/`Impl`-style names. | Clean Architecture, Clean Code | md |
| 13 | Automate any check a reviewer has flagged twice; review comments are bug reports against the toolchain. | Pragmatic, Accelerate | skill (`harvest-review-comments`, planned) |
| 14 | Use delivery metrics (lead time, deploy freq, CFR) as team-level trend lines only; never surface them to the agent as objectives. | Accelerate + Goodhart | none (a rule for the human) |
| 15 | Meaningful names, delete dead code, one abstraction level per function, guard clauses. | Clean Code's surviving core | none (Claude does this reliably) |

The highest-value always-loaded tokens go to rules that fight the model's priors
(#3–#5, #9). Deterministic properties (#2 import direction, #8 tests-pass, secret
scanning) belong in hooks, never prose. Judgment-heavy review (#10, #11) belongs in
a separate agent lens so it isn't graded by the context that wrote the code.

## Per-book notes

### Clean Architecture (Martin, 2017)
**Keep:** the Dependency Rule (volatile details point toward stable policy); a
domain that runs without DB/network (fast hermetic tests are the biggest multiplier
on agent quality); boundaries only where independent change is genuinely expected;
screaming directory layout; testability as a design signal; thin wrappers at risky
vendor seams. **Discard:** the four-ring ceremony as a default (every layer is more
files an agent must load to trace one behavior), interface-per-class, DTOs
everywhere, SOLID as a package deal (Open/Closed as "extend without modifying"
fights modern practice — with tests, modifying is cheap and safe). **Position:**
YAGNI wins on *layer count*, Martin wins on *dependency direction*. Encode "domain
never imports I/O" as a mechanically-checked rule and stop there; an agent can add a
seam later in an afternoon, which was the expensive operation the ceremony insured
against.

### Clean Code (Martin, 2008)
The most contested of the five; the book's own worked refactorings are widely held
to be worse than the originals. **Keep:** names that carry the design (for an agent
doing grep-navigation, a precise name is the retrieval index); one level of
abstraction per function (the *altitude* idea, not the *length* dogma); no surprising
side effects; delete dead/commented-out code (it is false context an agent will
believe and extend); handle errors deliberately in one place; keep tests as clean as
production code (agents replicate sloppy tests a hundredfold); bounded boy-scout
rule. **Discard:** 2–4-line functions / "extract till you drop" (produces shallow
*entangled* fragments — strictly worse for an agent, each hop is another file load);
"comments are failures / code documents itself" (flatly wrong and the most damaging
idea for agentic work — contracts, invariants, and *why*-comments exist nowhere in
the code's text); OO-maximalism (polymorphism-over-switch, one-assert-per-test — an
exhaustive `match` over a sum type beats a class hierarchy in every 2026 language);
the book's example refactorings. **Position:** side with Ousterhout — deep modules
and information hiding minimize context-per-change, the binding constraint for both
human and agent. Concede Martin's naming and altitude discipline (Ousterhout doesn't
dispute them). On comments Ousterhout wins outright, and more so now that the
marginal reader is a model that can't ping the author on Slack.

### Tidy First? (Beck, 2023)
Least contested; best single fit for agentic work — a theory of *when* to
restructure, built on reversibility and small steps. **Keep:** never mix structural
and behavioral change (a pure-refactor diff verifies almost mechanically, freeing
review attention for the behavior diff); tidy-first only when it makes the imminent
change easier, else tidy-after or not at all (kills both refactoring guilt and
refactoring sprees — agents will "improve" indefinitely if allowed); small,
individually reversible steps (`git revert` of a small commit is the cheapest
incident response there is); coupling as the dominant cost of software; buy
optionality only when cheap; the standard micro-tidyings (guard clauses, dead-code
deletion, explaining variables, cohesion ordering) as the default cleanup
vocabulary. **Discard:** almost nothing; don't literalize the options-pricing
metaphor. **Position:** this *is* the synthesis of the Clean-vs-YAGNI fight —
structure exactly when and where the next behavioral change demands it, in separated
reversible increments. It converts design judgment (hard to delegate) into a
sequencing discipline (easy to encode and check).

### The Pragmatic Programmer (Hunt & Thomas, 2019)
Ages best — about feedback loops and responsibility, not a stack. **Keep:** DRY as
one authoritative home per piece of *knowledge* (guards both agent failure modes:
accidental duplication and coincidental *false* deduplication); tracer bullets (thin
end-to-end skeleton first — doubles as validation the agent understood the task, at
5% spend not 95%); crash early / assert invariants / no silent fallbacks (the single
most important standing order — agents systematically bias toward defensive
try/except-and-continue that turns loud bugs into quiet data corruption); bounded
broken-windows; automate every repeated action into one command (anything manual is
the step the agent skips or fakes); program deliberately, be able to explain why the
code works; design by contract (a stated contract is prompt material, comment, and
assertion at once); you own the outcome — "the AI wrote it" is the new "the intern
wrote it," not an excuse. **Discard as stated:** editor/keystroke fluency (leverage
moved to prompt/harness fluency), "learn a language a year" as a capability play,
plain-text evangelism (won). Invert the code-generator warning: the generator is now
the primary author, so the rule becomes "don't *merge* what you couldn't explain."

### Accelerate (Forsgren, Humble, Kim, 2018)
**Keep the practices:** small batches + continuous integration (agent throughput
makes big batches catastrophically unreviewable — survives on first principles);
automate the pipeline until releases are boring (every manual gate becomes a queue or
gets bypassed); loose coupling so a slice tests/deploys without cross-team
coordination; continuous quality gates, shift review left (the only scalable review
of agent code is the automated portion); four metrics as *directional team* signals
never individual targets (Goodhart applies double to agents); generative blame-free
culture. **Discard the science framing:** the causal claims (cross-sectional
self-reported survey via PLS-SEM supports "correlates in respondents," not "X drives
performance"); the elite/high/medium/low clusters as stable categories (DORA later
reshuffled them and redefined the stability metrics); the 24-capabilities path model
as a roadmap (thin independent validation). **Position:** the empirics are the
weakest here and it mostly doesn't matter — the load-bearing recommendations are
independently derivable and predate the book. Keep the practices, drop the "science
of" framing.

## Structural conventions (authoring skills / agents / hooks)

Adapted from Trail of Bits' `claude-code-config` and `skills` repos, and Anthropic's
skill-authoring guidance. Their security-domain *content* (semgrep, crypto, malware)
is discarded; only the structure is reused.

**The three layers, and how to choose:**
- **CLAUDE.md** — persistent, loaded every session, survives `/clear`. For standing
  rules and navigation that shape *every* turn. Spend its tokens only on rules that
  fight the model's priors; move reference-shaped material into a `references/` file.
- **Skill** — loaded on demand; teaches *how to approach* a category of task. Not a
  rote script — encode judgment, trade-offs, and decision criteria the model lacks.
- **Hook** — fires at a lifecycle point; *"structured prompt injection at opportune
  times,"* **not a security boundary** (a prompt injection can route around it).
  Block only unambiguous deterministic violations; warn (feed context back) on
  judgment calls.

**Skill authoring:**
- Frontmatter: `name` (kebab-case, gerund preferred — `slicing-prs` not `pr-slicer`;
  avoid `helper`/`utils`/`claude`), `description` (third-person, with explicit
  triggers — "Use when …", not "Helps with …"), optional `allowed-tools` (restrict
  to what's needed).
- Every `SKILL.md`: a `## When to Use` and a `## When NOT to Use` section.
- Keep `SKILL.md` under ~500 lines; use progressive disclosure — quick start first,
  details in linked `references/` / `workflows/` files. **One level deep:** SKILL.md
  links to files; those files don't chain onward. (Nested folders are fine; chained
  references are not.)
- Value-add over reference dumps: explain WHY and WHEN, document anti-patterns with
  the reason they're wrong. Prescriptiveness matches task risk (strict for fragile
  tasks, flexible for exploratory ones).

**Agent authoring:** an isolated review lens gets a **read-only** tool set so its
judgment isn't graded by the context that wrote the code. Name the class of finding
it hunts; give it the anti-patterns to look for and how to report them.

**Hook authoring:** PreToolUse hooks run on every matching call — performance is
critical. Prefer shell + `jq` over interpreter startup; fast-fail early (exit 0
immediately for non-matching input); favor regex over AST parsing and accept rare
false positives the model can rephrase around; anticipate false-positive shapes
(`which python`, `grep rm`, filenames). Exit-code contract: **exit 2 blocks**
(stderr fed back to Claude); exit 0 with JSON on stdout gives structured control
(`hookSpecificOutput.permissionDecision` = allow/deny/ask, `additionalContext` to
inject a soft warning). Keep hooks network- and secret-free.

## Sources

- Ousterhout ↔ Martin written debate: <https://github.com/johnousterhout/aposd-vs-clean-code>
- qntm, "It's probably time to stop recommending Clean Code": <https://qntm.org/clean>
- Keunwoo Lee, review of *Accelerate*: <https://keunwoo.com/notes/accelerate-devops/>
- Jez Humble, response to Lee: <https://medium.com/@jezhumble/response-to-keunwoo-lees-review-of-accelerate-611ef75cad3>
- Sallin et al., XP 2021, four-key-metrics validation: <https://link.springer.com/chapter/10.1007/978-3-030-78098-2_7>
- DORA metrics (post-book redefinitions): <https://dora.dev/guides/dora-metrics-four-keys/>
- Anthropic skill-authoring best practices: <https://platform.claude.com/docs/en/agents-and-tools/agent-skills/best-practices>
- Trail of Bits `claude-code-config`: <https://github.com/trailofbits/claude-code-config> · `skills`: <https://github.com/trailofbits/skills>
