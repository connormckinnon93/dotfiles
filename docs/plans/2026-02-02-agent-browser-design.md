# Agent-Browser Integration Design

Add Vercel Labs agent-browser to chezmoi-managed dotfiles for global browser automation capabilities in Claude Code.

## Overview

Agent-browser is a CLI tool from Vercel Labs that provides browser automation for AI agents. It uses a "Snapshot + Refs" system that reduces context usage by 93% compared to Playwright MCP.

## Components

### 1. CLI Installation (mise)

**File:** `dot_config/mise/config.toml`

```toml
"npm:agent-browser" = "latest"
```

Mise installs the CLI globally via its npm backend. Using `"latest"` for consistency with other npm tools.

### 2. Skill File (chezmoiexternal)

**File:** `.chezmoiexternal.toml.tmpl`

```toml
[".claude/skills/agent-browser/SKILL.md"]
    type = "file"
    url = "https://raw.githubusercontent.com/vercel-labs/agent-browser/main/skills/agent-browser/SKILL.md"
    refreshPeriod = "168h"
```

Downloads skill directly rather than cloning entire repo. Claude Code discovers skills from `~/.claude/skills/`.

### 3. Permissions

**File:** `.chezmoidata/claude.yaml`

```yaml
permissions:
  allow:
    - "Bash(agent-browser *)"
```

Permits all agent-browser commands. All subcommands are browser automation operations with similar risk profile.

### 4. Chromium Installation

**File:** `.chezmoiscripts/run_onchange_after_setup-agent-browser-chromium-darwin.sh.tmpl`

Script runs after mise installs agent-browser, downloads Chromium via `agent-browser install`.

## Decisions

| Decision | Rationale |
|----------|-----------|
| mise over npm script | User preference: brew > mise > npm |
| Download SKILL.md only | Simpler than cloning 50MB repo for one file |
| Wildcard permission | 40+ commands, all browser operations |
| Automatic Chromium | "It just works" preferred over manual step |

## Sources

- [vercel-labs/agent-browser](https://github.com/vercel-labs/agent-browser)
- [Agent-Browser Medium Article](https://medium.com/@richardhightower/agent-browser-ai-first-browser-automation-that-saves-93-of-your-context-window-7a2c52562f8c)
