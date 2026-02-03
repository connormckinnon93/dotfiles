# Agent-Browser Integration Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add Vercel Labs agent-browser CLI and skill to chezmoi-managed dotfiles for global browser automation in Claude Code.

**Architecture:** mise installs the CLI via npm backend, chezmoiexternal downloads the skill file, claude.yaml grants permissions, and a chezmoi script installs Chromium automatically.

**Tech Stack:** chezmoi, mise, npm (agent-browser), Claude Code skills

---

## Task 1: Add agent-browser to mise config

**Files:**
- Modify: `dot_config/mise/config.toml:9-11`

**Step 1: Add agent-browser to tools section**

Add after the Language Servers section:

```toml
# AI Agent Tools
"npm:agent-browser" = "latest"
```

The complete file should be:

```toml
[tools]
# Language Runtimes
node = "lts"
python = "latest"
ruby = "latest"
go = "latest"

# Language Servers (for Claude Code LSP plugins)
"npm:typescript-language-server" = "latest"
"npm:pyright" = "latest"
"go:golang.org/x/tools/gopls" = "latest"

# AI Agent Tools
"npm:agent-browser" = "latest"
```

**Step 2: Verify template renders**

Run: `chezmoi execute-template < dot_config/mise/config.toml`
Expected: File contents output without errors

**Step 3: Commit**

```bash
git add dot_config/mise/config.toml
git commit -m "feat(mise): add agent-browser CLI tool"
```

---

## Task 2: Add skill file download to chezmoiexternal

**Files:**
- Modify: `.chezmoiexternal.toml.tmpl:19` (append)

**Step 1: Add skill file entry**

Append to `.chezmoiexternal.toml.tmpl`:

```toml
# Agent-browser skill (browser automation for AI agents)
[".claude/skills/agent-browser/SKILL.md"]
    type = "file"
    url = "https://raw.githubusercontent.com/vercel-labs/agent-browser/main/skills/agent-browser/SKILL.md"
    refreshPeriod = "168h"
```

**Step 2: Verify URL is accessible**

Run: `curl -sI "https://raw.githubusercontent.com/vercel-labs/agent-browser/main/skills/agent-browser/SKILL.md" | head -1`
Expected: `HTTP/2 200`

**Step 3: Commit**

```bash
git add .chezmoiexternal.toml.tmpl
git commit -m "feat(chezmoi): add agent-browser skill download"
```

---

## Task 3: Add bash permissions for agent-browser

**Files:**
- Modify: `.chezmoidata/claude.yaml:108-109` (in allow section)

**Step 1: Add permission entry**

Add after the `Bash(mkdir *)` entry in the `allow` section:

```yaml
    # Browser automation (agent-browser CLI)
    - "Bash(agent-browser *)"
```

**Step 2: Verify YAML syntax**

Run: `yq eval '.permissions.allow' .chezmoidata/claude.yaml | tail -5`
Expected: Shows the new permission entry without YAML errors

**Step 3: Commit**

```bash
git add .chezmoidata/claude.yaml
git commit -m "feat(claude): add agent-browser bash permissions"
```

---

## Task 4: Create Chromium installation script

**Files:**
- Create: `.chezmoiscripts/run_onchange_after_setup-agent-browser-chromium-darwin.sh.tmpl`

**Step 1: Create the script**

Create file `.chezmoiscripts/run_onchange_after_setup-agent-browser-chromium-darwin.sh.tmpl`:

```bash
{{- if eq .chezmoi.os "darwin" -}}
#!/bin/bash
# mise config hash: {{ include "dot_config/mise/config.toml" | sha256sum }}

# Install Chromium for agent-browser after mise installs the CLI
if command -v agent-browser &> /dev/null; then
    echo "Installing Chromium for agent-browser..."
    agent-browser install
else
    echo "agent-browser not found in PATH, skipping Chromium install"
    echo "Run 'mise install' then 'agent-browser install' manually"
fi

{{ end -}}
```

**Step 2: Verify template renders**

Run: `chezmoi execute-template < .chezmoiscripts/run_onchange_after_setup-agent-browser-chromium-darwin.sh.tmpl`
Expected: Script contents with resolved hash, no template errors

**Step 3: Commit**

```bash
git add .chezmoiscripts/run_onchange_after_setup-agent-browser-chromium-darwin.sh.tmpl
git commit -m "feat(chezmoi): add agent-browser chromium install script"
```

---

## Task 5: Test chezmoi diff

**Step 1: Run chezmoi diff**

Run: `chezmoi diff`
Expected: Shows changes to:
- `~/.config/mise/config.toml` (agent-browser added)
- `~/.claude/skills/agent-browser/SKILL.md` (new file)
- `~/.claude/settings.json` (permissions updated)

**Step 2: Document any issues**

If diff shows unexpected changes, investigate before applying.

---

## Task 6: Apply and verify

**Step 1: Apply chezmoi changes**

Run: `chezmoi apply -v`
Expected: Files updated, scripts executed

**Step 2: Verify mise installed agent-browser**

Run: `which agent-browser`
Expected: Path like `~/.local/share/mise/installs/npm-agent-browser/...`

**Step 3: Verify skill file exists**

Run: `ls -la ~/.claude/skills/agent-browser/SKILL.md`
Expected: File exists with content

**Step 4: Verify permissions in settings**

Run: `jq '.permissions.allow | map(select(contains("agent-browser")))' ~/.claude/settings.json`
Expected: `["Bash(agent-browser *)"]`

**Step 5: Verify Chromium installed**

Run: `agent-browser --version`
Expected: Version number output (e.g., `0.8.6`)

---

## Task 7: Final commit and summary

**Step 1: Check git status**

Run: `git status`
Expected: Clean working tree (all changes committed in Tasks 1-4)

**Step 2: View commit log**

Run: `git log --oneline -5`
Expected: 4 commits for this feature
