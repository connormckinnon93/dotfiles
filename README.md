# Dotfiles

macOS dotfiles managed with [chezmoi](https://chezmoi.io/). One command bootstraps a complete development environment with 1Password secrets, Catppuccin theming, and modern CLI tools.

## Features

- **One-Command Setup** - Bootstraps Homebrew, packages, fonts, and system preferences
- **1Password Secrets** - SSH keys, commit signing, and credentials stay in your vault
- **Catppuccin Mocha** - Consistent colors across terminal, editor, git tools, and prompt
- **Modern CLI** - eza, bat, ripgrep, fd, delta replace ls, cat, grep, find, diff
- **Polyglot Runtimes** - Mise manages Node, Python, Ruby, and Go
- **Claude Code** - Superpowers plugins and episodic memory

## Quick Start

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --one-shot <github-username>
```

The `--one-shot` flag applies dotfiles then removes chezmoi (use `--apply` to keep it). Bootstrap installs Homebrew (SHA256-verified), 1Password CLI, packages, casks, fonts, configures macOS, and sets up runtimes via mise.

## Shell

| Tool | Purpose |
|------|---------|
| [zsh](https://www.zsh.org/) | Shell |
| [zap](https://github.com/zap-zsh/zap) | Plugin manager |
| [starship](https://starship.rs/) | Prompt |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart cd |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder |

**Plugins:** zsh-completions, fzf-tab, zsh-autosuggestions, zsh-history-substring-search, zsh-syntax-highlighting

## CLI Replacements

| Old | New | Why |
|-----|-----|-----|
| `ls` | [eza](https://github.com/eza-community/eza) | Icons, git status |
| `cat` | [bat](https://github.com/sharkdp/bat) | Syntax highlighting |
| `grep` | [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast, recursive |
| `find` | [fd](https://github.com/sharkdp/fd) | Intuitive syntax |
| `top` | [htop](https://htop.dev/) | Interactive |
| `diff` | [delta](https://github.com/dandavison/delta) | Side-by-side, colors |

## Development

**Version Control:** git (with aliases, delta), [gh](https://cli.github.com/), [lazygit](https://github.com/jesseduffield/lazygit), [gitleaks](https://github.com/gitleaks/gitleaks)

**Editors:** [neovim](https://neovim.io/) (LazyVim), [VS Code](https://code.visualstudio.com/)

**Containers:** [Docker Desktop](https://www.docker.com/products/docker-desktop/), [lazydocker](https://github.com/jesseduffield/lazydocker)

**Runtimes:** [mise](https://mise.jdx.dev/) (Node LTS, Python, Ruby, Go)

## Git

**Workflow:** Rebase pulls with auto-stash, fast-forward merges, auto-prune, SSH signing via 1Password

**Hooks:** Gitleaks blocks secrets; commit-msg enforces conventional format

**Aliases:**
```bash
git lg    # Log graph
git st    # Status
git df    # Diff stats
git go    # Checkout or create branch
```

## Applications

- **Browser:** Chrome
- **Terminal:** [Ghostty](https://ghostty.org/)
- **Passwords:** 1Password + CLI
- **AI:** Claude, Claude Code
- **Windows:** Rectangle
- **Fonts:** JetBrains Mono, Fira Code, Hack, Meslo LG (Nerd Fonts)

## Claude Code

**Plugins:** superpowers, episodic-memory, elements-of-style, double-shot-latte

**MCP:** Context7 (documentation lookup)

## Structure

```
.
├── .chezmoi.toml.tmpl           # Config (name/email prompts)
├── .chezmoidata/
│   ├── packages.yaml            # Brews, casks, extensions
│   └── claude.yaml              # Claude permissions
├── .chezmoiexternal.toml.tmpl   # External repos
├── .chezmoiscripts/             # Install scripts
├── dot_claude/                  # Claude Code
├── dot_config/                  # App configs
├── dot_gitconfig.tmpl           # Git
├── dot_zshenv.tmpl              # Environment
├── dot_zshrc.tmpl               # Shell
└── private_dot_ssh/             # SSH (1Password agent)
```

## Customization

**Add packages** in `.chezmoidata/packages.yaml`:

```yaml
darwin:
  brews:
    - your-package
  casks:
    - your-application
  vscodes:
    - publisher.extension-name
```

**Add runtimes** in `dot_config/mise/config.toml`:

```toml
[tools]
node = "lts"
python = "latest"
```

**Add variables** to `dot_zshenv.tmpl` (all shells) or `dot_zshrc.tmpl` (interactive).

Run `chezmoi apply`.

## macOS Preferences

- **Dock:** Auto-hide, fast animations
- **Finder:** Hidden files, extensions, path bar
- **Keyboard:** Fast repeat, short delay
- **Trackpad:** Tap to click
- **Screenshots:** `~/Screenshots`, PNG

## Security

- 1Password stores SSH keys and secrets
- 1Password SSH agent handles connections
- All commits signed via 1Password
- Gitleaks blocks accidental secret commits
- Homebrew installer SHA256-verified

## Requirements

- macOS
- Internet (initial setup)
- 1Password
