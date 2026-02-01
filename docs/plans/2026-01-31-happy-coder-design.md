# Happy Coder Integration

Add Happy Coder to enable mobile access to Claude Code sessions.

## Overview

Happy Coder is a CLI wrapper + mobile app that provides end-to-end encrypted remote access to Claude Code. Run `happy` instead of `claude` to enable mobile connectivity.

## Scope

**In scope:**
- Happy Coder installation via Homebrew tap

**Out of scope:**
- Shell aliases or workflow changes
- Configuration management (auth is interactive by design)

## Design

### Add tap and package to packages.yaml

```yaml
packages:
  darwin:
    taps:
      - 'slopus/tap'
    brews:
      # ... existing packages ...
      # AI TOOLS
      - 'slopus/tap/happy-coder'  # Mobile access to Claude Code
```

### Update install script to handle taps

Modify `.chezmoiscripts/run_onchange_before_install-packages-darwin.sh.tmpl`:

```bash
{{- if eq .chezmoi.os "darwin" -}}
#!/bin/bash
# MacOS build version: {{ output "sw_vers" "--buildVersion" }}

brew bundle --file=/dev/stdin <<EOF
{{ range .packages.darwin.taps -}}
tap {{ . | quote }}
{{ end -}}
{{ range .packages.darwin.brews -}}
brew {{ . | quote }}
{{ end -}}
{{ range .packages.darwin.casks -}}
cask {{ . | quote }}
{{ end -}}
{{ range .packages.darwin.vscodes -}}
vscode {{ . | quote }}
{{ end -}}
EOF

{{ end -}}
```

## Changes Summary

| File | Change |
|------|--------|
| `.chezmoidata/packages.yaml` | Add `taps` section, add `happy-coder` to brews |
| `.chezmoiscripts/run_onchange_before_install-packages-darwin.sh.tmpl` | Add tap iteration |

## Security Notes

Homebrew taps are third-party repositories. The `slopus/tap` is maintained by the Happy Coder developers.

| Concern | Mitigation |
|---------|------------|
| Third-party tap | Same maintainers as the npm package; open source |
| Auto-updates | Homebrew updates on `brew upgrade`; review changelog |
| Happy Coder itself | See security review in conversation |

## Usage After Install

```bash
# Start Claude Code with mobile access enabled
happy

# On first run, scan QR code with Happy mobile app
# Subsequently, just run 'happy' and connect from phone
```

## Future Extensions

- Shell alias (`alias claude=happy`) if you want mobile access by default
- Self-hosted relay server config if privacy requirements increase
