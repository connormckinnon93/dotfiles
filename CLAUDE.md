# CLAUDE.md

Chezmoi-managed dotfiles for macOS.

## Quick Reference

```bash
chezmoi apply              # Apply changes to ~
chezmoi diff               # Preview changes
chezmoi edit <file>        # Edit source file
chezmoi add <file>         # Add dotfile
chezmoi re-add             # Update from ~
```

## Structure

- **`.chezmoidata/`** - YAML data for templates
- **`.chezmoiscripts/`** - Bootstrap and install scripts
- **`dot_*`** - Deploys to `~/.*` (`dot_gitconfig` → `~/.gitconfig`)
- **`private_*`** - Restricted permissions
- **`*.tmpl`** - Go templates

## Key Files

| File | Purpose |
|------|---------|
| `.chezmoidata/packages.yaml` | Homebrew packages, casks, VS Code extensions |
| `.chezmoidata/claude.yaml` | Claude Code plugins and MCP permissions |
| `.chezmoiexternal.toml.tmpl` | External repos (zap, Claude plugins) |
| `dot_zshrc.tmpl` | Shell configuration |
| `dot_gitconfig.tmpl` | Git settings and signing |

## Templates

Go template syntax with chezmoi functions:

```go
{{ .chezmoi.homeDir }}                // User's home directory
{{ .email }}                          // From .chezmoi.toml
{{ onepasswordRead "op://..." }}      // 1Password secret
{{ include "file" | sha256sum }}      // Change detection
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

## Script Prefixes

- `run_before_*` - Before deployment
- `run_after_*` - After deployment
- `run_onchange_*` - When content changes
- `*_darwin.sh.tmpl` - macOS only

## Git Hooks

- **Pre-commit**: Gitleaks blocks secrets
- **Commit-msg**: Enforces `type(scope): message`

## Testing

```bash
chezmoi diff                    # Preview
chezmoi apply --dry-run         # Simulate
chezmoi apply -v                # Verbose
```

## Chezmoi Dotfiles

This machine's dotfiles are managed by chezmoi. Claude may edit source files and preview changes but must never apply them.

**Find the source directory:**

```bash
chezmoi source-path
```

**Key files to edit:**

| File | Purpose |
|------|---------|
| `.chezmoidata/packages.yaml` | Homebrew packages, casks, VS Code extensions |
| `.chezmoidata/claude.yaml` | Claude Code permissions and MCP config |
| `dot_zshrc.tmpl` | Shell configuration and aliases |
| `dot_gitconfig.tmpl` | Git settings and signing |

**Workflow:**

1. Find source: `chezmoi source-path`
2. Edit files in the source directory
3. Preview: `chezmoi diff`
4. Stop here — a human runs `chezmoi apply`

**Never run `chezmoi apply` or `chezmoi init`.**

## Requirements

- macOS (all scripts target Darwin)
- 1Password CLI (for `onepasswordRead`)
- Homebrew (`/opt/homebrew` - Apple Silicon only)
