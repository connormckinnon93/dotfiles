# Episodic-Memory to Claude-Mem Migration

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Replace episodic-memory plugin with claude-mem for better token efficiency and richer memory capture.

**Architecture:** Add thedotmack marketplace to chezmoi config, swap plugin references, update permissions and CLAUDE.md instructions. Templates auto-handle marketplace cloning and registration.

**Tech Stack:** Chezmoi (dotfiles), YAML data files, Go templates

---

## Background

| Aspect | episodic-memory | claude-mem |
|--------|-----------------|------------|
| MCP Server | `episodic-memory` | `mcp-search` |
| Tools | 2 (search, read) | 4 (search, timeline, get_observations, __IMPORTANT) |
| Skill | `episodic-memory:search-conversations` | `mem-search` |
| Token Efficiency | Full results | 3-layer progressive (~10x savings) |

---

### Task 1: Add thedotmack Marketplace

**Files:**
- Modify: `.chezmoidata/packages.yaml:5-16`

**Step 1: Edit packages.yaml to add new marketplace and remove episodic-memory**

Replace the `claude_marketplaces` block:

```yaml
claude_marketplaces:
  claude-plugins-official:
    source: "github"
    repo: "anthropics/claude-plugins-official"
    plugins: []
  superpowers-marketplace:
    source: "github"
    repo: "obra/superpowers-marketplace"
    plugins:
      - "superpowers"
      - "elements-of-style"
  thedotmack:
    source: "github"
    repo: "thedotmack/claude-mem"
    plugins:
      - "claude-mem"
```

**Step 2: Verify YAML syntax**

Run: `yq eval '.claude_marketplaces | keys' .chezmoidata/packages.yaml`
Expected: `["claude-plugins-official", "superpowers-marketplace", "thedotmack"]`

**Step 3: Commit**

```bash
git add .chezmoidata/packages.yaml
git commit -m "feat(claude): add thedotmack marketplace for claude-mem"
```

---

### Task 2: Update Permissions

**Files:**
- Modify: `.chezmoidata/claude.yaml:23-33`

**Step 1: Replace episodic-memory skill permission with claude-mem**

Find line 25:
```yaml
    - "Skill(episodic-memory:*)"
```

Replace with:
```yaml
    - "Skill(claude-mem:*)"
```

**Step 2: Replace episodic-memory MCP tool permissions with claude-mem**

Find lines 32-33:
```yaml
    - "mcp__plugin_episodic-memory_episodic-memory__search"
    - "mcp__plugin_episodic-memory_episodic-memory__read"
```

Replace with:
```yaml
    - "mcp__plugin_claude-mem_mcp-search__search"
    - "mcp__plugin_claude-mem_mcp-search__timeline"
    - "mcp__plugin_claude-mem_mcp-search__get_observations"
```

**Step 3: Verify YAML syntax**

Run: `yq eval '.permissions.allow | .[] | select(test("claude-mem"))' .chezmoidata/claude.yaml`
Expected: Four lines containing `claude-mem`

**Step 4: Commit**

```bash
git add .chezmoidata/claude.yaml
git commit -m "feat(claude): update permissions for claude-mem MCP tools"
```

---

### Task 3: Update CLAUDE.md Instructions

**Files:**
- Modify: `dot_claude/private_CLAUDE.md:75-79`

**Step 1: Update the memory search instruction**

Find lines 76-77:
```markdown
- **BEFORE** starting **ANY** task **YOU MUST ALWAYS**:
    - Dispatch `episodic-memory:search-conversations` agent to search for relevant past work
```

Replace with:
```markdown
- **BEFORE** starting **ANY** task **YOU MUST ALWAYS**:
    - Use the `mem-search` skill to search for relevant past work
```

**Step 2: Commit**

```bash
git add dot_claude/private_CLAUDE.md
git commit -m "docs(claude): update memory instructions for claude-mem"
```

---

### Task 4: Apply and Verify

**Files:**
- None (verification only)

**Step 1: Preview chezmoi changes**

Run: `chezmoi diff`
Expected: Changes to `~/.claude/settings.json` and external repo list

**Step 2: Apply chezmoi changes**

Run: `chezmoi apply -v`
Expected: Success, new marketplace cloned

**Step 3: Verify marketplace cloned**

Run: `ls ~/.claude/plugins/marketplaces/thedotmack`
Expected: Directory exists with claude-mem plugin files

**Step 4: Verify settings updated**

Run: `jq '.enabledPlugins | keys | .[] | select(contains("claude-mem"))' ~/.claude/settings.json`
Expected: `"claude-mem@thedotmack"`

---

### Task 5: Install and Test Plugin

**Step 1: Restart Claude Code**

Close and reopen Claude Code to reload configuration.

**Step 2: Install the plugin**

Run in Claude Code: `/plugin install claude-mem`
Expected: Plugin installs successfully

**Step 3: Verify plugin appears**

Run in Claude Code: `/plugin list`
Expected: `claude-mem` appears in installed plugins

**Step 4: Test memory search**

Run in Claude Code: `/mem-search` or invoke the `mem-search` skill
Expected: Memory search interface works

**Step 5: Check worker service (optional)**

Run: `curl -s http://localhost:37777 | head -5`
Expected: HTML response from claude-mem web UI

---

## Rollback

If claude-mem fails, revert the three commits:
```bash
git revert HEAD~3..HEAD
chezmoi apply -v
```

## Notes

- Historical episodic-memory data remains at `~/.config/superpowers/conversation-archive/` but won't be searchable via claude-mem
- claude-mem requires Bun runtime (auto-installed by plugin)
- Port 37777 must be available for worker service
