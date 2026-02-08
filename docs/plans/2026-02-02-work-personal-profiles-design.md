# Work/Personal Profile System Design

## Overview

Add profile-based selective installation to chezmoi dotfiles. Machines are either "work" or "personal", affecting which packages install and which files deploy.

## Profile Selection

Interactive prompt on first `chezmoi init`:

```
Machine profile
1. personal
2. work
```

Stored in `~/.config/chezmoi/chezmoi.toml` as `.profile` variable, available in all templates.

## Changes

### 1. `.chezmoi.toml.tmpl`

Add profile prompt before email/name:

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

### 2. `.chezmoidata/packages.yaml`

Restructure from flat list to categorized:

```yaml
packages:
  darwin:
    common:
      taps: [...]
      brews: [...]    # Most current packages
      casks: [...]
      vscodes: [...]

    personal:
      brews:
        - 'slopus/tap/happy-coder'
      casks: []
      vscodes: []

    work:
      brews: []
      casks: []       # Add work-specific apps here
      vscodes: []
```

### 3. `.chezmoiignore` → `.chezmoiignore.tmpl`

Template-based conditional file exclusion:

```go
docs/*
README.md
CLAUDE.md

{{- if eq .profile "work" }}
# Skip on work machines
{{- end }}

{{- if eq .profile "personal" }}
# Skip on personal machines
{{- end }}
```

### 4. Install Script

Update to merge common + profile packages:

```sh
{{ $profile := .profile }}
{{ $common := .packages.darwin.common }}
{{ $profilePkgs := index .packages.darwin $profile }}

brew install {{ range $common.brews }}{{ . }} {{ end }}{{ range $profilePkgs.brews }}{{ . }} {{ end }}
```

## Migration

Existing machines prompt for profile on next `chezmoi apply` via `promptChoiceOnce`.

## Example: Happy-Coder

Currently in flat list. After refactor:
- Moves to `packages.darwin.personal.brews`
- Work machines won't install it
- Personal machines continue to get it
