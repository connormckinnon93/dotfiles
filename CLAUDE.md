# chezmoi dotfiles

Managed with [chezmoi](https://chezmoi.io). `.chezmoiroot` points at `home/`, so
`home/` is the source root and its contents map to `~`. Anything at the repo root
(this file, `README.md`, `zdotdir/`) is outside chezmoi's view and is never applied.

macOS is the only supported target today; package installs assume Homebrew.

## Working in this repo

```sh
chezmoi apply           # render source → ~ (add --dry-run to preview)
chezmoi diff            # show pending changes to the target
chezmoi cat ~/.claude/settings.json   # render one file (e.g. to test modify_settings.json)
chezmoi edit <target>   # edit the source of a target file
chezmoi add <target>    # start managing an existing file (respects .chezmoiignore)
```

Source lives in `home/`; never edit files under `~` directly — edit the source and
apply.

## Machine profile

`chezmoi init` prompts for a `profile` (`personal` or `work`, default `personal`),
stored in `[data].profile` in `home/.chezmoi.toml.tmpl`. It is a general-purpose
switch available to **every** template — not only package installs. Use it to vary
anything per machine class:

- **Packages:** `home/.chezmoiscripts/darwin/run_onchange_before_10-install-packages.sh.tmpl`
  has `{{ if eq .profile "personal" }}` / `"work"` blocks that `concat` profile-specific
  brews/casks/taps onto the base lists (base lists apply to both profiles). The personal
  block adds the `granted` brew plus, nested under `{{ if not .headless }}`, the
  gaming/desktop casks (steam, epic-games, …); the work block is an empty placeholder.
- **Ignored files:** add a `{{ if eq .profile "work" }} … {{ end }}` block to
  `home/.chezmoiignore.tmpl` to drop personal-only configs on a work machine.
- **Any other template:** reference `.profile` directly.

Set it non-interactively by re-running init, keyed by the **prompt string** (not the
data key): `chezmoi init --promptChoice "Machine profile=work"`.

## Ephemeral machines

`chezmoi init` also computes `ephemeral` (bool, default false), stored in
`[data].ephemeral`. Ephemeral means a throwaway machine (cloud/VM/container/CI) that
should get a leaner setup; "stable" is simply `ephemeral = false`. It is auto-detected
from the environment — GitHub Codespaces (`CODESPACES`), VS Code remote containers
(`REMOTE_CONTAINERS_IPC`), or a `root`/`ubuntu`/`vagrant`/`vscode` username — and
otherwise prompts when interactive, falling back to ephemeral when run
non-interactively (e.g. CI provisioning).

Like `.profile`, it is available to every template. The install-packages script has
`{{ if not .ephemeral }}` (stable-only) and `{{ if .ephemeral }}` blocks ready to fill.

A separate `headless` bool (also auto-detected, also in `[data]`) marks machines with
no display. It is **orthogonal** to `ephemeral` — a persistent server can be
headless+stable, and an ephemeral desktop VM can have a screen. It is set `true`
alongside `ephemeral` in container environments, prompted independently when
interactive, and assumed non-interactively. Use it to gate GUI installs/config. In
install-packages the `{{ if not .headless }}` block holds the GUI casks (1password,
aerospace, brave-browser, ghostty, tailscale-app, zed, …), the GUI-only brews
(borders, dockutil), **and the third-party taps** they need (FelixKratz/formulae,
nikitabobko/tap) — so a headless box taps nothing. The `{{ if .headless }}` block
holds CLI counterparts of GUI tools (e.g. the `tailscale` CLI instead of the
`tailscale-app` cask). CLI tools stay in the base list.

**Gotcha for maintainers:** because the non-interactive branch forces
`ephemeral = true` and `headless = true`, do not run `chezmoi init` without a TTY on a
normal workstation — it would flip the cached values. (`chezmoi apply` is unaffected;
it does not regenerate the config.) To re-init from a non-TTY context, run it under a
PTY: `python3 -c 'import pty,sys; sys.exit(pty.spawn(["chezmoi","init","--promptBool","headless=false","--promptBool","ephemeral=false"]))'`.

## `.chezmoiscripts/` — setup scripts

Scripts that run on `chezmoi apply`. OS-specific scripts live in an OS subdirectory
(`darwin/`, and `linux/`/`windows/` if ever added); cross-OS scripts would go at the
top level of `.chezmoiscripts/`.

```
home/.chezmoiscripts/darwin/
├── run_once_before_05-install-rosetta.sh.tmpl              # Rosetta 2 (personal+headed+arm64)
├── run_onchange_before_10-install-packages.sh.tmpl         # brew bundle (taps, brews, casks)
├── run_onchange_after_20-install-mise.sh.tmpl              # mise install global runtimes
├── run_once_after_30-build-bat-cache.sh.tmpl              # bat cache --build
├── run_onchange_after_40-configure-keyboard.sh.tmpl        # press-and-hold off
├── run_onchange_after_42-configure-trackpad.sh.tmpl        # scroll/force-click/swipe-nav
├── run_onchange_after_44-configure-dock.sh.tmpl            # autohide, recents, gestures
├── run_once_after_45-configure-power.sh.tmpl               # pmset -c sleep 0 (personal+headed+stable)
├── run_onchange_after_46-configure-finder.sh.tmpl          # extensions, path, view, sort
├── run_onchange_after_48-configure-ui.sh.tmpl              # window anims, save-to-disk
├── run_onchange_after_50-configure-dock-icons.sh.tmpl      # dockutil: strip default icons
├── run_onchange_after_60-configure-spaces.sh.tmpl          # spans-displays (aerospace)
└── run_onchange_after_70-configure-notification-center.sh.tmpl  # disable Notification Center
```

The `40`–`70` `configure-*` scripts apply macOS `defaults`/system settings. They
follow a `NN-verb-noun` name (numeric prefix for ordering + descriptive concern), are
mostly wrapped in `{{ if not .headless }}` (a display is required, so they render empty
on headless boxes — hence the `.tmpl` extension), and are split one-concern-per-file.
The exception is `45-configure-power`, which is additionally gated on `not .ephemeral`
(keeping a throwaway VM awake is pointless) and uses `run_once_` rather than
`run_onchange_` since `pmset` takes no input that would change.
`configure-dock` (behavior: autohide/gestures) is deliberately separate from
`configure-dock-icons` (contents: the `dockutil` removal list).

### OS gating

chezmoi has **no** built-in notion of OS directories — the `darwin/` name alone does
nothing. Gating is done in `home/.chezmoiignore.tmpl`, whose non-darwin block ignores
the macOS-only paths: `.chezmoiscripts/darwin/**` plus the macOS-only configs
(`.config/aerospace`, `.config/borders`, `.config/homebrew`). Add to that block when
introducing a new macOS-only path, or add a parallel block for another OS. Because
only the matching OS's paths are active, scripts inside `darwin/` need no internal
`{{ if eq .chezmoi.os ... }}` wrapper.

### Numeric ordering convention

Filenames carry a two-digit prefix (`10-`, `20-`, `30-`) to make run order explicit.
chezmoi's actual ordering rules (verified empirically — see below):

1. **`before_` vs `after_` is a global partition.** Every `run_*_before_` script runs
   before every `run_*_after_` script, regardless of number or directory.
2. **Within a partition, top-level scripts run before subdirectory scripts.** A number
   does **not** interleave a `darwin/` script with a top-level one — e.g. a top-level
   `before_15-` runs before `darwin/before_10-`.
3. **Numbers only order scripts within the same directory and the same before/after
   partition.**

Practical rule: **keep a given before/after group entirely within one directory.** As
long as all OS-specific scripts stay in their OS directory (and we don't split a group
across top-level + subdir), the numeric prefixes order exactly as written. Today all
scripts are in `darwin/`, so ordering is simply all `before_` (`05` → `10`) then all
`after_` (`20` → `30` → `40` … → `70`).

To re-verify rule changes, drop throwaway `run_onchange_before_/after_` scripts that
`echo` to a log into a temp source dir and `chezmoi apply --source … --destination …`
with an isolated `HOME`.

### Gotcha: only scripts allowed in `.chezmoiscripts/`

Every entry in `.chezmoiscripts/` must be a script — any other file (e.g. a plain
`CLAUDE.md` or `README.md`) makes **all** chezmoi commands fail with `not a script`.
That is why this documentation lives at the repo root rather than beside the scripts.
(A dot-prefixed file like `.notes.md` is ignored by chezmoi and would be safe, but is
not auto-discovered by tooling.)

## CI

`.github/workflows/ci.yml` (repo root, outside chezmoi's view) renders the full
source state for every supported machine shape on push/PR: a macOS matrix over
`profile` × `headless` (real `chezmoi init` under a PTY, `apply --dry-run`,
shellcheck of every rendered setup script) plus an ubuntu job for the
non-interactive ephemeral path (asserts `ephemeral`/`headless` auto-detect true,
then dry-runs — deliberately with **no** `op` binary, since headless shapes must
render without 1Password).

The macOS jobs stub the 1Password CLI with a fake `op` script. The stub answers
`op signin --raw` (chezmoi's account mode calls it before reading) and returns
shaped output per secret reference — notably JSON for the AWS SSO `accounts`
field. **When adding a new `onepasswordRead` call whose value must parse (JSON,
etc.), extend the stub's `case` in the workflow accordingly.**

## Workflow

`main` is protected by a repository ruleset (`protect-main`): no direct pushes;
changes land via pull request with all CI checks green (zero approvals required
— solo repo). Auto-merge and head-branch auto-delete are enabled, so the loop
is:

```sh
git switch -c <topic>
git push -u origin <topic>
gh pr create --fill
gh pr merge --auto --merge
```

**Coupling to CI:** the ruleset's required status checks are the six CI *job
names* (`macOS personal headed`, …, `prek hooks`). Renaming or adding a job in
`ci.yml` requires updating the ruleset's `required_status_checks` to match —
otherwise merges wait forever on a check that will never report (rename) or
skip a job that should gate (add).

## Git hooks

`.pre-commit-config.yaml` (repo root, outside chezmoi's view) defines
prek-managed hooks: gitleaks secret scanning (the repo is public — only `op://`
references may be committed, and the hook guards against `chezmoi add`-ing a
rendered file containing real secrets), pre-commit-hooks hygiene checks,
actionlint, and shellcheck on plain `.sh` files (rendered `.sh.tmpl` scripts are
CI's job). `run_once_after_80-install-git-hooks` installs the hooks into
`.git/hooks` on `chezmoi apply`; the `hooks` CI job runs `prek run --all-files`
as the server-side backstop. Rule: commits must stay fast and work offline —
hooks must never need the network or 1Password (full rendering belongs in CI).

## Homebrew

- `home/.install-homebrew.sh` — `read-source-state.pre` hook (registered in
  `home/.chezmoi.toml.tmpl`); installs Homebrew on a fresh macOS machine.
- `home/.chezmoiscripts/darwin/run_onchange_before_10-install-packages.sh.tmpl` —
  taps (with `brew trust`), brews, and casks via `brew bundle`.
- `home/dot_config/homebrew/brew.env` — `HOMEBREW_*` environment settings.
- `home/dot_config/zsh/exact_dot_zshrc.d/brew.zsh` — `eval "$(brew shellenv)"` for shells.

## Claude Code config (`~/.claude`)

`home/dot_claude/` maps to `~/.claude`. We manage a **curated** surface and leave
everything else (transcripts, caches, per-machine state, secrets) alone. All of it
is OS-agnostic, so nothing here is gated by profile/headless/ephemeral.

The classification split, and why each mechanism:

- `modify_settings.json` → `~/.claude/settings.json`. A **modify-template**, not an
  owned file, *because Claude Code rewrites `settings.json` at runtime* (`/config`,
  `/model`, permission "always allow", …). The template reads the current file on
  stdin, pins our baseline keys, and leaves app-written keys untouched. It also holds
  the pinned `hooks` block, whose `command` paths are built from `.chezmoi.homeDir`
  (same pattern as `statusLine`).
- `CLAUDE.md`, `references/`, `skills/`, `agents/`, `hooks/` → **owned files**, since
  Claude Code does not rewrite them (auto-memory writes under `projects/`, not
  `CLAUDE.md`). `hooks/executable_*.sh` carry the `executable_` prefix for the +x bit.

**Curation model (important):** `.chezmoiignore` has no negation, so the curated
surface is an *allowlist by omission* — chezmoi only manages files that exist in
`home/dot_claude/`, and the `.claude/**` block in `home/.chezmoiignore.tmpl` blocks
`chezmoi add` from scooping runtime/state/secret paths into the source tree. To add a
new managed surface: drop the source file under `home/dot_claude/`; if it generates
runtime siblings, add them to that ignore block. `~/.claude.json` (OAuth + machine
state) stays fully ignored.

**CI note:** `modify_settings.json` is a Go template, not JSON — it's in the
`check-json` exclude in `.pre-commit-config.yaml`. Hook scripts are plain `.sh`,
linted by the `prek`/`shellcheck` hooks; keep them network- and 1Password-free.
