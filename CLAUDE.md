# chezmoi dotfiles

Managed with [chezmoi](https://chezmoi.io). `.chezmoiroot` points at `home/`, so
`home/` is the source root and its contents map to `~`. Anything at the repo root
(this file, `README.md`, `zdotdir/`) is outside chezmoi's view and is never applied.

macOS is the only supported target today; package installs assume Homebrew.

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
├── run_onchange_after_20-mise-install.sh.tmpl              # mise install global runtimes
├── run_once_after_30-bat-cache.sh                          # bat cache --build
├── run_onchange_after_40-configure-keyboard.sh.tmpl        # press-and-hold off
├── run_onchange_after_42-configure-trackpad.sh.tmpl        # scroll/force-click/swipe-nav
├── run_onchange_after_44-configure-dock.sh.tmpl            # autohide, recents, gestures
├── run_onchange_after_46-configure-finder.sh.tmpl          # extensions, path, view, sort
├── run_onchange_after_48-configure-ui.sh.tmpl              # window anims, save-to-disk
├── run_onchange_after_50-configure-dock-icons.sh.tmpl      # dockutil: strip default icons
├── run_onchange_after_60-configure-spaces.sh.tmpl          # spans-displays (aerospace)
└── run_onchange_after_70-configure-notificationcenter.sh.tmpl  # disable Notification Center
```

The `40`–`70` `configure-*` scripts apply macOS `defaults`/system settings. They
follow a `NN-verb-noun` name (numeric prefix for ordering + descriptive concern), are
each wrapped in `{{ if not .headless }}` (a display is required, so they render empty
on headless boxes — hence the `.tmpl` extension), and are split one-concern-per-file.
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

## Homebrew

- `home/.install-homebrew.sh` — `read-source-state.pre` hook (registered in
  `home/.chezmoi.toml.tmpl`); installs Homebrew on a fresh macOS machine.
- `home/.chezmoiscripts/darwin/run_onchange_before_10-install-packages.sh.tmpl` —
  taps (with `brew trust`), brews, and casks via `brew bundle`.
- `home/dot_config/homebrew/brew.env` — `HOMEBREW_*` environment settings.
- `home/dot_config/zsh/dot_zshrc.d/brew.zsh` — `eval "$(brew shellenv)"` for shells.
