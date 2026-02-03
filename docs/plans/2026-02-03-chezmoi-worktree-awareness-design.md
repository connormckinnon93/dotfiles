# Chezmoi Worktree Awareness

## Problem

Chezmoi defaults its source directory to `~/.local/share/chezmoi`. When working from a git worktree (e.g. `~/.claude-squad/worktrees/cm/fix-chezmoi-bugs`), running `chezmoi diff` or `chezmoi apply --dry-run` reads from the default source, not the worktree. Changes in the worktree go untested.

A hardcoded path in the bootstrap hook compounds the problem:

```toml
[hooks.read-source-state.pre]
    command = ".local/share/chezmoi/.chezmoiscripts/.bootstrap-dependencies.sh"
```

This path breaks when `--source` points elsewhere.

## Solution

### 1. Shell wrapper in `dot_zshrc.tmpl`

A `chezmoi()` function that detects whether the current directory belongs to a chezmoi source tree. If so, it injects `--source` automatically.

```bash
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

**Detection logic:** The presence of `.chezmoidata/` at the git root marks a chezmoi source. If this directory differs from the default source, the wrapper passes `--source`.

**Why a shell function:** It works for both humans and Claude agents without per-worktree setup. Agents inherit the shell environment and need no special knowledge.

### 2. Fix hardcoded bootstrap path in `.chezmoi.toml.tmpl`

Replace the absolute path with a chezmoi template variable:

```toml
# Before
command = ".local/share/chezmoi/.chezmoiscripts/.bootstrap-dependencies.sh"

# After
command = "{{ .chezmoi.sourceDir }}/.chezmoiscripts/.bootstrap-dependencies.sh"
```

### 3. Claude permissions in `.chezmoidata/claude.yaml`

Grant Claude read/write access to the chezmoi source directory and allow preview commands. Deny destructive commands.

**Allow:**
- File read/write: `~/.local/share/chezmoi/**`
- Commands: `chezmoi diff`, `chezmoi apply --dry-run`, `chezmoi cat`, `chezmoi data`, `chezmoi source-path`, `chezmoi managed`

**Deny:**
- `chezmoi apply` (without `--dry-run`)
- `chezmoi init`

### 4. Documentation

**CLAUDE.md** -- Add a "Chezmoi Dotfiles" section:

- How to find the source directory (`chezmoi source-path`)
- Key files and their purposes
- The workflow: edit source, preview with `chezmoi diff`, stop
- Explicit instruction: never run `chezmoi apply`

**README.md** -- Add a "Working with Worktrees" section:

- The shell wrapper detects worktrees and passes `--source`
- No special flags needed; `chezmoi diff` works from any worktree
- Manual override: `chezmoi --source=/path/to/worktree diff`

## Files Changed

| File | Change |
|------|--------|
| `dot_zshrc.tmpl` | Add `chezmoi()` shell wrapper |
| `.chezmoi.toml.tmpl` | Fix bootstrap hook path |
| `.chezmoidata/claude.yaml` | Add source path permissions and allowed commands |
| `CLAUDE.md` | Add chezmoi workflow section |
| `README.md` | Add worktree usage section |

## Out of Scope

- Skills for Claude self-modification (future work)
- Per-worktree setup files (`.envrc`, direnv)
- Custom aliases beyond the single wrapper function
- `chezmoi apply` permission for Claude
