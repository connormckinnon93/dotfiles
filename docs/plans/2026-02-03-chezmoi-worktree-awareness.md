# Chezmoi Worktree Awareness Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Make chezmoi commands work correctly from git worktrees and grant Claude read/preview access to the chezmoi source directory.

**Architecture:** A shell wrapper function auto-detects chezmoi worktrees and injects `--source`. Claude permissions allow source file editing and preview commands but deny `chezmoi apply`.

**Tech Stack:** zsh, chezmoi (Go templates), Claude Code permissions (YAML)

**Design doc:** `docs/plans/2026-02-03-chezmoi-worktree-awareness-design.md`

---

### Task 1: Fix hardcoded bootstrap hook path

**Files:**
- Modify: `.chezmoi.toml.tmpl:11-12`

**Step 1: Verify current hardcoded path**

Run: `chezmoi execute-template < .chezmoi.toml.tmpl 2>&1 || true`

Confirm the hook command resolves to a hardcoded `.local/share/chezmoi/` path.

**Step 2: Replace hardcoded path with template variable**

In `.chezmoi.toml.tmpl`, change line 12 from:

```toml
    command = ".local/share/chezmoi/.chezmoiscripts/.bootstrap-dependencies.sh"
```

to:

```toml
    command = "{{ .chezmoi.sourceDir }}/.chezmoiscripts/.bootstrap-dependencies.sh"
```

**Step 3: Verify the template renders correctly**

Run: `chezmoi execute-template < .chezmoi.toml.tmpl 2>&1 | grep command`

Expected: `command = "/Users/cm/.local/share/chezmoi/.chezmoiscripts/.bootstrap-dependencies.sh"` (full absolute path instead of relative)

**Step 4: Commit**

```bash
git add .chezmoi.toml.tmpl
git commit -m "fix(chezmoi): use sourceDir template var in bootstrap hook path"
```

---

### Task 2: Add chezmoi shell wrapper to zshrc

**Files:**
- Modify: `dot_zshrc.tmpl` (append after line 2, before Zap plugin manager)

**Step 1: Add the chezmoi wrapper function**

Insert after the early-exit guard (line 2) and before the Zap plugin manager section (line 4):

```bash
# Chezmoi worktree awareness
# Auto-detects chezmoi source trees in git worktrees and injects --source
chezmoi() {
  local git_root
  if git_root=$(git rev-parse --show-toplevel 2>/dev/null) \
    && [[ -d "$git_root/.chezmoidata" ]] \
    && [[ "$git_root" != "${CHEZMOI_SOURCE_DIR:-$HOME/.local/share/chezmoi}" ]]; then
    command chezmoi --source="$git_root" "$@"
  else
    command chezmoi "$@"
  fi
}
```

**Step 2: Verify template renders without errors**

Run: `chezmoi cat ~/.zshrc 2>&1 | head -20`

Expected: The wrapper function appears in the rendered output between the early-exit guard and the Zap section.

**Step 3: Commit**

```bash
git add dot_zshrc.tmpl
git commit -m "feat(shell): add chezmoi worktree-aware wrapper function"
```

---

### Task 3: Add chezmoi permissions to claude.yaml

**Files:**
- Modify: `.chezmoidata/claude.yaml` (permissions section)

**Step 1: Add chezmoi read/preview commands to the `allow` list**

In `.chezmoidata/claude.yaml`, add a new block under the `allow:` section after the "Read operations" group (around line 96):

```yaml
    # Chezmoi - read/preview operations
    - "Bash(chezmoi source-path*)"
    - "Bash(chezmoi diff*)"
    - "Bash(chezmoi cat *)"
    - "Bash(chezmoi data*)"
    - "Bash(chezmoi managed*)"
    - "Bash(chezmoi execute-template*)"
    - "Bash(chezmoi apply --dry-run*)"
```

**Step 2: Add chezmoi destructive commands to the `deny` list**

In the `deny:` section (around line 259), add:

```yaml
    # Chezmoi - destructive operations (human must apply)
    - "Bash(chezmoi apply*)"
    - "Bash(chezmoi init*)"
```

Note: The `deny` for `chezmoi apply*` takes precedence over the `allow` for `chezmoi apply --dry-run*`. Verify this works in Step 3. If deny takes full precedence, move `chezmoi apply --dry-run*` to `ask` instead and remove from `allow`.

**Step 3: Verify the rendered settings.json includes new permissions**

Run: `chezmoi cat ~/.claude/settings.json 2>&1 | jq '.permissions'`

Expected: The `allow` array includes the chezmoi read commands. The `deny` array includes `chezmoi apply*` and `chezmoi init*`.

**Step 4: Commit**

```bash
git add .chezmoidata/claude.yaml
git commit -m "feat(permissions): add chezmoi read/preview permissions for Claude"
```

---

### Task 4: Add chezmoi workflow section to CLAUDE.md

**Files:**
- Modify: `CLAUDE.md` (append new section)

**Step 1: Add the chezmoi dotfiles section**

Append to `CLAUDE.md` before the Requirements section (before line 80):

```markdown
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
```

**Step 2: Commit**

```bash
git add CLAUDE.md
git commit -m "docs(claude): add chezmoi dotfiles workflow for agents"
```

---

### Task 5: Add worktree section to README.md

**Files:**
- Modify: `README.md` (add section before Structure)

**Step 1: Add the worktree section**

Insert a "Working with Worktrees" section in `README.md` before the "Structure" section (before line 86):

```markdown
## Working with Worktrees

A shell wrapper detects when you are inside a git worktree of this repository and passes `--source` to chezmoi automatically. No special flags are needed:

```bash
cd ~/.claude-squad/worktrees/cm/some-branch
chezmoi diff    # reads from the worktree, not ~/.local/share/chezmoi
```

To override manually:

```bash
chezmoi --source=/path/to/worktree diff
```
```

**Step 2: Commit**

```bash
git add README.md
git commit -m "docs(readme): add worktree usage section"
```

---

### Task 6: Verify end-to-end

**Step 1: Run chezmoi diff to check all changes render correctly**

Run: `chezmoi diff --source=$(pwd) 2>&1 | head -80`

Verify: No template errors. The diff shows expected changes to `~/.zshrc`, `~/.claude/settings.json`, etc.

**Step 2: Verify permissions render correctly**

Run: `chezmoi cat --source=$(pwd) ~/.claude/settings.json 2>&1 | jq '.permissions.deny'`

Expected: Array includes `"Bash(chezmoi apply*)"` and `"Bash(chezmoi init*)"`.

Run: `chezmoi cat --source=$(pwd) ~/.claude/settings.json 2>&1 | jq '.permissions.allow' | grep chezmoi`

Expected: Array includes chezmoi read commands (`source-path`, `diff`, `cat`, `data`, `managed`, `execute-template`, `apply --dry-run`).

**Step 3: Verify zshrc renders correctly**

Run: `chezmoi cat --source=$(pwd) ~/.zshrc 2>&1 | head -20`

Expected: The `chezmoi()` wrapper function appears after the early-exit guard.
