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
