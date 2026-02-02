# Cowork-like Workspace for Claude Code

**Date:** 2026-02-01
**Status:** Proposed
**Author:** Claude (with user guidance)

## Summary

Add cowork-like abilities to Claude Code by integrating official Anthropic knowledge-work and document-skills plugins, and creating a dedicated `~/Workspace/` directory with workspace-specific instructions.

## Motivation

Claude Cowork (in Claude Desktop) provides powerful knowledge work capabilities:
- Document creation (Word, Excel, PowerPoint, PDF)
- File organization and management
- Research synthesis
- Parallel workstream coordination

These capabilities are built on Claude Code's foundations but packaged for the desktop app. This design brings similar abilities to Claude Code via the plugin system.

## Goals

1. **Integrate official Anthropic plugins** for document creation and knowledge work
2. **Create a dedicated workspace** with cowork-optimized configuration
3. **Manage via dotfiles** for reproducible setup across machines

## Non-Goals

- Replicating Cowork's GUI or VM sandbox
- Building custom skills from scratch (use official plugins instead)
- Project-level plugin enablement (not supported by Claude Code)

## Architecture

### Current State

```
~/.claude/
├── settings.json           # Global settings + enabled plugins
├── CLAUDE.md              # Global instructions
├── mcp.json               # MCP servers
└── plugins/
    └── marketplaces/
        ├── superpowers-marketplace/
        └── thedotmack/
```

### Proposed State

```
~/.claude/
├── settings.json           # + new plugins enabled
├── CLAUDE.md              # Global (unchanged)
└── plugins/
    └── marketplaces/
        ├── superpowers-marketplace/     # Existing
        ├── thedotmack/                  # Existing
        ├── anthropic-knowledge-work/    # NEW
        └── anthropic-agent-skills/      # NEW

~/Workspace/                             # NEW
└── .claude/
    └── CLAUDE.md           # Workspace-specific instructions (overrides global)
```

### How It Works

1. **Plugin Registration:** Chezmoi clones Anthropic repos to `~/.claude/plugins/marketplaces/`
2. **Plugin Enablement:** Existing template adds plugins to `enabledPlugins` in settings.json
3. **Workspace Override:** When Claude Code runs in `~/Workspace/`, it loads the local `.claude/CLAUDE.md` instead of global

## Anthropic Plugins to Integrate

### anthropics/knowledge-work-plugins

11 plugins for knowledge work, including:

| Plugin | Purpose |
|--------|---------|
| productivity | Tasks, calendars, daily workflows |
| sales | Prospect research, call prep, outreach |
| customer-support | Ticket triage, KB articles |
| product-management | Specs, roadmaps, research synthesis |
| marketing | Content drafting, campaigns |
| legal | Contract review, compliance |
| finance | Journal entries, reconciliation |
| data | SQL, dashboards, analysis |
| enterprise-search | Unified search across tools |

### anthropics/skills

Document creation skills:

| Skill | Capabilities |
|-------|-------------|
| docx | Create, edit, analyze Word documents |
| pdf | Extract, create, merge, split PDFs |
| pptx | Create presentations from notes |
| xlsx | Spreadsheets with formulas and formatting |

## Implementation

### Step 1: Update `.chezmoidata/claude.yaml`

Add new marketplaces:

```yaml
claude_marketplaces:
  # ... existing ...

  anthropic-knowledge-work:
    source: "github"
    repo: "anthropics/knowledge-work-plugins"
    plugins:
      - "productivity"

  anthropic-agent-skills:
    source: "github"
    repo: "anthropics/skills"
    plugins:
      - "docx"
      - "pdf"
      - "pptx"
      - "xlsx"
```

Add permissions:

```yaml
permissions:
  allow:
    # ... existing ...
    - "Skill(anthropic-knowledge-work:*)"
    - "Skill(anthropic-agent-skills:*)"
```

### Step 2: Update `.chezmoiexternal.toml.tmpl`

Clone the new marketplace repos:

```toml
["{{ .chezmoi.homeDir }}/.claude/plugins/marketplaces/anthropic-knowledge-work"]
type = "git-repo"
url = "https://github.com/anthropics/knowledge-work-plugins.git"
refreshPeriod = "168h"

["{{ .chezmoi.homeDir }}/.claude/plugins/marketplaces/anthropic-agent-skills"]
type = "git-repo"
url = "https://github.com/anthropics/skills.git"
refreshPeriod = "168h"
```

### Step 3: Create Workspace Directory

**File:** `dot_Workspace/dot_claude/CLAUDE.md`

```markdown
# Workspace

You are operating in a dedicated knowledge workspace at ~/Workspace.

## Available Skills

You have access to document creation skills:
- **docx** - Create and edit Word documents
- **pdf** - Create, extract, merge PDFs
- **pptx** - Create presentations
- **xlsx** - Create spreadsheets with formulas

## Working Patterns

1. **File Organization** - Keep outputs organized in subdirectories
2. **Document Creation** - Use appropriate skill for each format
3. **Parallel Work** - Coordinate subagents for complex tasks
4. **Safety** - Confirm before deleting files

## Scope

Work should generally stay within ~/Workspace unless explicitly directed elsewhere.
```

### Step 4: Ensure Directory Exists

**File:** `dot_Workspace/empty`

Empty file to ensure chezmoi creates the directory.

## Files Changed

| File | Change | Purpose |
|------|--------|---------|
| `.chezmoidata/claude.yaml` | Modify | Add marketplaces + permissions |
| `.chezmoiexternal.toml.tmpl` | Modify | Clone repos |
| `dot_Workspace/empty` | Create | Ensure directory |
| `dot_Workspace/dot_claude/CLAUDE.md` | Create | Workspace instructions |

## Verification

After `chezmoi apply`:

```bash
# Verify marketplaces cloned
ls ~/.claude/plugins/marketplaces/anthropic-knowledge-work/
ls ~/.claude/plugins/marketplaces/anthropic-agent-skills/

# Verify workspace created
ls -la ~/Workspace/.claude/

# Test in workspace
cd ~/Workspace && claude
# Ask: "What document skills are available?"
```

## Risks and Mitigations

| Risk | Mitigation |
|------|------------|
| Plugins change structure | Pin to specific commit in .chezmoiexternal |
| Workspace CLAUDE.md conflicts with global | Test override behavior |
| Permission errors with new skills | Add to allow list proactively |

## Future Enhancements

1. **Multiple workspaces** - Research, Writing, Projects directories
2. **Workspace initialization script** - Create new spaces anywhere
3. **Per-plugin configuration** - `.claude/plugin-name.local.md` files

## References

- [anthropics/knowledge-work-plugins](https://github.com/anthropics/knowledge-work-plugins)
- [anthropics/skills](https://github.com/anthropics/skills)
- [Claude Code Skills Docs](https://code.claude.com/docs/en/skills)
- [Introducing Cowork](https://claude.com/blog/cowork-research-preview)
