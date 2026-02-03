# Work/Personal Profile System Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add profile-based selective installation so work machines don't install personal tools (like happy-coder) and vice versa.

**Architecture:** Add a `profile` variable to chezmoi config (prompted on init), restructure packages.yaml into common/personal/work sections, update install script to merge common + selected profile.

**Tech Stack:** chezmoi templates (Go text/template), YAML data files, bash/brew bundle

---

### Task 1: Add Profile Prompt to chezmoi.toml.tmpl

**Files:**
- Modify: `.chezmoi.toml.tmpl`

**Step 1: Add profile prompt before existing prompts**

Edit `.chezmoi.toml.tmpl` to add the profile choice:

```go
{{- $profile := promptChoiceOnce . "profile" "Machine profile" (list "personal" "work") -}}
{{- $email := promptStringOnce . "email" "Email Address" -}}
{{- $name := promptStringOnce . "name" "Full Name" -}}


[data]
    profile = {{ $profile | quote }}
    email = {{ $email | quote }}
    name = {{ $name | quote }}

[hooks.read-source-state.pre]
    command = ".local/share/chezmoi/.chezmoiscripts/.bootstrap-dependencies.sh"
```

**Step 2: Verify template syntax**

Run: `chezmoi execute-template < .chezmoi.toml.tmpl`

Expected: Prompts for profile (shows "personal" and "work" options), then email, then name.

**Step 3: Commit**

```bash
git add .chezmoi.toml.tmpl
git commit -m "feat(profile): add profile prompt to chezmoi config"
```

---

### Task 2: Restructure packages.yaml with Profile Categories

**Files:**
- Modify: `.chezmoidata/packages.yaml`

**Step 1: Restructure packages under common/personal/work**

The current flat structure:
```yaml
packages:
  darwin:
    taps: [...]
    brews: [...]
```

Becomes nested:
```yaml
packages:
  darwin:
    common:
      taps:
        - 'slopus/tap'
        - 'oven-sh/bun'
      brews:
        # All current brews EXCEPT happy-coder
        - 'git'
        - 'gh'
        # ... (all others)
        - 'claude-squad'
      casks:
        # All current casks
        - 'google-chrome'
        # ... (all others)
      vscodes:
        # All current vscodes
        - 'anthropic.claude-code'
        # ... (all others)

    personal:
      taps: []
      brews:
        - 'slopus/tap/happy-coder'  # Mobile access to Claude Code
      casks: []
      vscodes: []

    work:
      taps: []
      brews: []
      casks: []
      vscodes: []
```

Move ALL current packages to `common` EXCEPT `slopus/tap/happy-coder` which goes to `personal.brews`.

**Step 2: Validate YAML syntax**

Run: `yq . .chezmoidata/packages.yaml`

Expected: Valid YAML output with nested structure.

**Step 3: Commit**

```bash
git add .chezmoidata/packages.yaml
git commit -m "refactor(packages): restructure into common/personal/work categories"
```

---

### Task 3: Update Install Script for Profile-Based Packages

**Files:**
- Modify: `.chezmoiscripts/run_onchange_before_install-packages-darwin.sh.tmpl`

**Step 1: Update script to merge common + profile packages**

Replace the current script with:

```go
{{- if eq .chezmoi.os "darwin" -}}
#!/bin/bash
# MacOS build version: {{ output "sw_vers" "--buildVersion" }}
# Profile: {{ .profile }}

brew bundle --file=/dev/stdin <<EOF
{{- $common := .packages.darwin.common }}
{{- $profilePkgs := index .packages.darwin .profile }}
{{ range $common.taps -}}
tap {{ . | quote }}
{{ end -}}
{{ range $profilePkgs.taps -}}
tap {{ . | quote }}
{{ end -}}
{{ range $common.brews -}}
brew {{ . | quote }}
{{ end -}}
{{ range $profilePkgs.brews -}}
brew {{ . | quote }}
{{ end -}}
{{ range $common.casks -}}
cask {{ . | quote }}
{{ end -}}
{{ range $profilePkgs.casks -}}
cask {{ . | quote }}
{{ end -}}
{{ range $common.vscodes -}}
vscode {{ . | quote }}
{{ end -}}
{{ range $profilePkgs.vscodes -}}
vscode {{ . | quote }}
{{ end -}}
EOF

{{ end -}}
```

Key change: Uses `index .packages.darwin .profile` to dynamically select the profile's packages.

**Step 2: Test template expansion**

Run: `chezmoi execute-template < .chezmoiscripts/run_onchange_before_install-packages-darwin.sh.tmpl`

Expected: Valid bash script with common packages + profile-specific packages listed.

**Step 3: Commit**

```bash
git add .chezmoiscripts/run_onchange_before_install-packages-darwin.sh.tmpl
git commit -m "feat(install): merge common + profile packages in install script"
```

---

### Task 4: Convert .chezmoiignore to Template

**Files:**
- Rename: `.chezmoiignore` → `.chezmoiignore.tmpl`
- Modify: `.chezmoiignore.tmpl`

**Step 1: Rename to template**

```bash
git mv .chezmoiignore .chezmoiignore.tmpl
```

**Step 2: Add conditional sections**

Edit `.chezmoiignore.tmpl`:

```go
docs/*
README.md
CLAUDE.md

{{- if eq .profile "work" }}
# Files skipped on work machines (add as needed)
{{- end }}

{{- if eq .profile "personal" }}
# Files skipped on personal machines (add as needed)
{{- end }}
```

**Step 3: Verify template syntax**

Run: `chezmoi execute-template < .chezmoiignore.tmpl`

Expected: Output shows the ignore patterns (conditional sections empty for now).

**Step 4: Commit**

```bash
git add .chezmoiignore.tmpl
git commit -m "refactor(ignore): convert chezmoiignore to template for profile conditionals"
```

---

### Task 5: Test End-to-End

**Step 1: Run chezmoi diff**

Run: `chezmoi diff`

Expected: Shows pending changes. The install script should now include profile-based logic.

**Step 2: Verify data is accessible**

Run: `chezmoi data | grep profile`

Expected: Shows `profile: personal` or `profile: work` depending on what was selected.

**Step 3: Verify generated Brewfile**

Run: `chezmoi cat ~/.chezmoiscripts/run_onchange_before_install-packages-darwin.sh`

Expected: Shows the merged package list. If profile is "personal", should include `happy-coder`. If "work", should not.

---

### Task 6: Final Commit and Summary

**Step 1: Verify all changes**

Run: `git status && git log --oneline -5`

Expected: Clean working tree with 4 commits for this feature.

**Step 2: Create summary commit if needed**

If any loose changes remain, commit them.

---

## Verification Checklist

After implementation:
- [ ] `chezmoi data` shows `.profile` variable
- [ ] `chezmoi diff` runs without template errors
- [ ] Personal profile includes `happy-coder` in generated install script
- [ ] Work profile excludes `happy-coder` from generated install script
- [ ] `.chezmoiignore.tmpl` parses correctly
