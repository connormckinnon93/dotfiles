# Dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io/), optimized for macOS development with a focus on security, automation, and developer experience.

## Features

- **Automated Setup** - Single command bootstraps entire development environment
- **Security-First** - 1Password integration for secrets, gitleaks pre-commit hooks, SSH commit signing
- **Consistent Theming** - Catppuccin Mocha across all tools (terminal, editor, git tools, prompt)
- **Modern CLI Tools** - Curated replacements for traditional Unix tools
- **Multi-Language Support** - Mise-managed runtimes for Node, Python, Ruby, and Go
- **AI-Enhanced Development** - Claude Code with superpowers plugins and episodic memory

## Quick Start

```bash
# Install chezmoi and apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply <github-username>
```

The bootstrap process will:
1. Install Homebrew (with SHA256 verification)
2. Install 1Password CLI for secret management
3. Install all packages, casks, and fonts
4. Configure macOS system preferences
5. Set up development tool runtimes via mise

## What's Included

### Shell Environment

| Tool | Purpose |
|------|---------|
| [zsh](https://www.zsh.org/) | Default shell |
| [zap](https://github.com/zap-zsh/zap) | Minimal zsh plugin manager |
| [starship](https://starship.rs/) | Cross-shell prompt with git integration |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smarter cd command |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder for files and history |

**Zsh Plugins:**
- `zsh-completions` - Enhanced completion system
- `fzf-tab` - Fuzzy finder for tab completion
- `zsh-autosuggestions` - Fish-like autosuggestions
- `zsh-history-substring-search` - History search
- `zsh-syntax-highlighting` - Command syntax highlighting

### Modern CLI Replacements

| Original | Replacement | Description |
|----------|-------------|-------------|
| `ls` | [eza](https://github.com/eza-community/eza) | Modern ls with icons and git status |
| `cat` | [bat](https://github.com/sharkdp/bat) | Syntax-highlighted cat |
| `grep` | [ripgrep](https://github.com/BurntSushi/ripgrep) | Fast recursive search |
| `find` | [fd](https://github.com/sharkdp/fd) | User-friendly find |
| `top` | [htop](https://htop.dev/) | Interactive process viewer |
| `diff` | [delta](https://github.com/dandavison/delta) | Beautiful git diffs |

### Development Tools

**Version Control:**
- [git](https://git-scm.com/) with extensive aliases and delta integration
- [gh](https://cli.github.com/) - GitHub CLI
- [lazygit](https://github.com/jesseduffield/lazygit) - Terminal UI for git
- [gitleaks](https://github.com/gitleaks/gitleaks) - Secret scanning pre-commit hook

**Editors:**
- [neovim](https://neovim.io/) with LazyVim configuration
- [VS Code](https://code.visualstudio.com/) with curated extensions

**Containers:**
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [lazydocker](https://github.com/jesseduffield/lazydocker) - Terminal UI for Docker

**Runtime Management:**
- [mise](https://mise.jdx.dev/) - Polyglot runtime manager (Node LTS, Python, Ruby, Go)

### Git Configuration

**Workflow Optimizations:**
- Rebase-based pulls with auto-stash
- Fast-forward only merges
- Auto-prune on fetch
- Conventional commit message enforcement
- SSH commit signing via 1Password

**Pre-commit Hooks:**
- Secret scanning with gitleaks (detects API keys, tokens)
- Commit message format validation (conventional commits)

**Useful Aliases:**
```bash
git lg    # Pretty log with graph
git st    # Short status
git df    # Diff with stats
git go    # Smart checkout/create branch
```

### Applications (Casks)

- **Browser:** Google Chrome
- **Terminal:** [Ghostty](https://ghostty.org/)
- **Password Manager:** 1Password + CLI
- **AI Tools:** Claude, Claude Code
- **Window Management:** Rectangle
- **Fonts:** JetBrains Mono, Fira Code, Hack, Meslo LG (all Nerd Font variants)

### Claude Code Configuration

**Enabled Plugins:**
- `superpowers` - Enhanced skill framework
- `episodic-memory` - Cross-conversation learning
- `the-elements-of-style` - Writing quality
- `double-shot-latte` - Development workflows

**MCP Servers:**
- Context7 - Documentation and code snippet lookup

## Directory Structure

```
.
├── .chezmoi.toml.tmpl           # Chezmoi config (prompts for name/email)
├── .chezmoidata/
│   ├── packages.yaml            # Package definitions (brews, casks, extensions)
│   └── claude.yaml              # Claude Code tool permissions
├── .chezmoiexternal.toml.tmpl   # External git repos (zap, claude plugins)
├── .chezmoiscripts/
│   ├── .bootstrap-dependencies.sh
│   ├── run_onchange_before_install-packages-darwin.sh.tmpl
│   ├── run_onchange_after_install-mise-tools-darwin.sh.tmpl
│   ├── run_onchange_after_config-machine-darwin.sh.tmpl
│   └── run_after_symlink-vscode-darwin.sh.tmpl
├── dot_claude/                  # Claude Code configuration
├── dot_config/
│   ├── gh/                      # GitHub CLI
│   ├── ghostty/                 # Terminal emulator
│   ├── git/hooks/               # Git hooks (pre-commit, commit-msg)
│   ├── gitleaks/                # Secret detection rules
│   ├── lazydocker/              # Docker TUI
│   ├── lazygit/                 # Git TUI
│   ├── mise/                    # Runtime manager
│   ├── nvim/                    # Neovim (LazyVim)
│   ├── starship.toml            # Shell prompt
│   └── vscode/                  # VS Code settings
├── dot_gitconfig.tmpl           # Git configuration
├── dot_gitattributes            # Git attributes
├── dot_gitignore                # Global gitignore
├── dot_zshenv.tmpl              # Zsh environment variables
├── dot_zshrc.tmpl               # Zsh runtime configuration
├── empty_dot_hushlogin          # Suppress login message
└── private_dot_ssh/             # SSH configuration (1Password agent)
```

## Customization

### Adding Packages

Edit `.chezmoidata/packages.yaml`:

```yaml
darwin:
  brews:
    - your-package
  casks:
    - your-application
  vscodes:
    - publisher.extension-name
```

Then run `chezmoi apply`.

### Adding Mise Tools

Edit `dot_config/mise/config.toml`:

```toml
[tools]
node = "lts"
python = "latest"
your-tool = "version"
```

### Environment Variables

Add to `dot_zshenv.tmpl` for variables needed by all shells, or `dot_zshrc.tmpl` for interactive shells only.

## macOS Preferences

The setup script configures sensible macOS defaults:

- **Dock:** Auto-hide, fast animations
- **Finder:** Show hidden files, extensions, path bar
- **Keyboard:** Fast key repeat, short delay
- **Trackpad:** Tap to click
- **Screenshots:** Save to `~/Screenshots` as PNG

## Security

- **1Password Integration:** SSH keys and secrets managed via 1Password
- **SSH Agent:** Uses 1Password's SSH agent for all connections
- **Commit Signing:** All commits signed with SSH key via 1Password
- **Secret Scanning:** Pre-commit hook detects accidentally committed secrets
- **Supply Chain:** Homebrew installer verified with SHA256 checksum

## Requirements

- macOS (Darwin) - scripts are macOS-specific
- Internet connection for initial setup
- 1Password account (for secrets management)
