# dotfiles

macOS dotfiles, managed with [chezmoi](https://chezmoi.io). `home/` is the
source root ([`.chezmoiroot`](.chezmoiroot)) and maps to `~`; everything else at
the repo root (CI, hooks config, this file) is outside chezmoi's view.

## Install

```sh
chezmoi init --apply connormckinnon93
```

`init` prompts for name, email, AWS region, and a machine profile
(`personal`/`work`), and detects two more shape flags — `headless` (no display →
no GUI apps) and `ephemeral` (throwaway VM/container/CI → leaner setup). Every
template can branch on these, so one repo renders correctly on a personal
desktop, a work laptop, or a disposable cloud box. Homebrew is installed
automatically before the first apply if missing.

**Prerequisite on headed machines:** templates resolve `op://` references at
apply time, so 1Password must be signed in before the first apply can render.
On a fresh Mac: `brew install --cask 1password`, open it and sign in, then
enable Settings → Developer → *Integrate with 1Password CLI*, and re-run the
install command. (A pre-hook checks for this and fails with these same
instructions rather than a cryptic render error; headless machines render
without 1Password and skip the check.)

## What's managed

- **Shell & terminal** — zsh (with abbr), starship, ghostty, zellij, atuin,
  readline
- **Editors & tools** — nvim, zed, git (+ lazygit, gh), bat, ripgrep, mise,
  aerospace, borders
- **Packages** — Homebrew taps/brews/casks via `brew bundle`, varied per
  profile/shape
- **macOS settings** — keyboard, trackpad, Dock, Finder, power, Spaces,
  notifications (`home/.chezmoiscripts/darwin/`)
- **Claude Code** — a curated slice of `~/.claude`: pinned `settings.json` keys
  via a modify-template (the app owns the rest of the file), a PreToolUse guard
  hook, and reference docs; runtime state and secrets are never tracked
- **Secrets** — never in the repo: only `op://` references, resolved at apply
  time by the 1Password CLI

## Recovery

If a machine dies, config restore is the Install command above — but it sits at
the end of a dependency chain worth knowing before you need it:

1. **1Password** first. The SSH key (auth *and* commit signing) lives only in
   the 1Password vault — never on disk — so account recovery (another signed-in
   device, or the Emergency Kit, which is kept offline outside this repo) is
   the root of everything.
2. **GitHub** next: SSH access comes from the vault key via the 1Password
   agent.
3. **This repo**: `chezmoi init --apply connormckinnon93` (see the 1Password
   prerequisite above).
4. Everything else: sign in to Tailscale, `gh auth login`, and app accounts as
   prompted.

**What a restore does *not* bring back** — this repo manages config, not state.
Lost with the machine unless separately backed up: atuin shell history
(`auto_sync = false` is deliberate — history stays local), Claude Code
transcripts/projects, Obsidian vaults, browser profiles, Docker volumes, and
`~/.config/zsh/.zshrc.local`. Anything on that list you'd miss needs a machine
backup (e.g. Time Machine) — chezmoi won't save it.

## How it works

- `main` is protected; changes land by PR with all CI checks green, then
  auto-merge.
- CI renders the full source state for every machine shape (profile × headless
  on macOS, plus a non-interactive Linux ephemeral job with no 1Password) and
  shellchecks every rendered script.
- [prek](https://github.com/j178/prek)-managed git hooks run gitleaks,
  actionlint, shellcheck, and hygiene checks locally; installed automatically on
  `chezmoi apply`.

Maintainer notes and conventions live in [CLAUDE.md](CLAUDE.md).
