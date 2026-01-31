# CLAUDE.md

Chezmoi-managed dotfiles for macOS development.

## Quick Reference

```bash
chezmoi apply              # Apply changes to home directory
chezmoi diff               # Preview pending changes
chezmoi edit <file>        # Edit managed file (opens source)
chezmoi add <file>         # Add new dotfile to management
chezmoi re-add             # Update all managed files from home
```

## Repository Structure

- **`.chezmoidata/`** - YAML data files merged into template context
- **`.chezmoiscripts/`** - Lifecycle scripts (bootstrap, package install, macOS config)
- **`dot_*`** - Files deployed to `~/.*` (e.g., `dot_gitconfig` → `~/.gitconfig`)
- **`private_*`** - Files with restricted permissions
- **`*.tmpl`** - Go templates processed by chezmoi

## Key Files

| File | Purpose |
|------|---------|
| `.chezmoidata/packages.yaml` | Homebrew packages, casks, VS Code extensions |
| `.chezmoidata/claude.yaml` | Claude Code plugin marketplaces and MCP permissions |
| `.chezmoiexternal.toml.tmpl` | External git repos (zap, Claude plugins) |
| `dot_zshrc.tmpl` | Shell configuration and aliases |
| `dot_gitconfig.tmpl` | Git settings, aliases, signing config |

## Templating

Templates use Go template syntax with chezmoi functions:

```go
{{ if eq .chezmoi.os "darwin" }}     // OS conditional
{{ .chezmoi.arch }}                   // arm64 or amd64
{{ .email }}                          // User data from .chezmoi.toml
{{ onepasswordRead "op://..." }}      // 1Password secrets
{{ include "file" | sha256sum }}      // Content hashing for change detection
```

## Adding Packages

Edit `.chezmoidata/packages.yaml`:

```yaml
darwin:
  brews:
    - package-name
  casks:
    - application-name
  vscodes:
    - publisher.extension
```

## Script Naming Conventions

- `run_before_*` - Runs before file deployment
- `run_after_*` - Runs after file deployment
- `run_onchange_*` - Runs only when content hash changes
- `*_darwin.sh.tmpl` - macOS-only scripts

## Validation

Git hooks enforce:
- **Pre-commit**: Gitleaks secret scanning (blocks API keys, tokens)
- **Commit-msg**: Conventional commits format (`type(scope): message`)

## Testing Changes

```bash
chezmoi diff                    # See what would change
chezmoi apply --dry-run         # Simulate apply
chezmoi apply -v                # Apply with verbose output
```

## Platform Notes

- macOS-only (Darwin) - all scripts target macOS
- Requires 1Password CLI for secrets (`onepasswordRead` template function)
- Uses Homebrew (arm64 path: `/opt/homebrew`, Intel: `/usr/local`)
