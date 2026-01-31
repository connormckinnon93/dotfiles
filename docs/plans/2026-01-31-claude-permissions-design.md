# Claude Code Permissions Configuration

Global permission settings for autonomous development across Ruby, Python, TypeScript, and Go projects.

## Philosophy

The permission model follows a trust gradient:

- **Allow**: Routine development operations - safe, reversible, low-impact
- **Ask**: Operations crossing trust boundaries - network, system, packages
- **Deny**: Irreversible destructive actions - blocked entirely

## Configuration

```yaml
permissions:
  defaultMode: "acceptEdits"

  allow:
    # Built-in tools
    - "WebFetch"
    - "WebSearch"
    - "Read"
    - "Edit"
    - "Write"
    - "Glob"
    - "Grep"

    # MCP tools
    - "mcp__context7__resolve-library-id"
    - "mcp__context7__query-docs"
    - "mcp__plugin_episodic-memory_episodic-memory__search"
    - "mcp__plugin_episodic-memory_episodic-memory__read"

    # Read operations
    - "Bash(cat *)"
    - "Bash(head *)"
    - "Bash(tail *)"
    - "Bash(ls *)"
    - "Bash(find *)"
    - "Bash(grep *)"
    - "Bash(rg *)"
    - "Bash(tree *)"
    - "Bash(wc *)"
    - "Bash(file *)"
    - "Bash(which *)"
    - "Bash(type *)"

    # Git - local operations
    - "Bash(git status*)"
    - "Bash(git log*)"
    - "Bash(git diff*)"
    - "Bash(git show*)"
    - "Bash(git branch*)"
    - "Bash(git add *)"
    - "Bash(git commit *)"
    - "Bash(git checkout *)"
    - "Bash(git switch *)"
    - "Bash(git stash*)"
    - "Bash(git fetch*)"

    # Testing - all languages
    - "Bash(npm test*)"
    - "Bash(npm run test*)"
    - "Bash(npm run lint*)"
    - "Bash(npm run format*)"
    - "Bash(pnpm test*)"
    - "Bash(pnpm run test*)"
    - "Bash(pnpm run lint*)"
    - "Bash(yarn test*)"
    - "Bash(yarn lint*)"
    - "Bash(pytest*)"
    - "Bash(python -m pytest*)"
    - "Bash(go test*)"
    - "Bash(cargo test*)"
    - "Bash(bundle exec rspec*)"
    - "Bash(bundle exec rake test*)"
    - "Bash(rspec *)"
    - "Bash(rake test*)"
    - "Bash(make test*)"
    - "Bash(vitest*)"
    - "Bash(jest *)"

    # Linting & formatting
    - "Bash(eslint *)"
    - "Bash(prettier *)"
    - "Bash(black *)"
    - "Bash(ruff *)"
    - "Bash(mypy *)"
    - "Bash(python -m black*)"
    - "Bash(python -m ruff*)"
    - "Bash(python -m mypy*)"
    - "Bash(bundle exec rubocop*)"

    # Build commands
    - "Bash(npm run build*)"
    - "Bash(pnpm run build*)"
    - "Bash(yarn build*)"
    - "Bash(go build*)"
    - "Bash(cargo build*)"
    - "Bash(make)"
    - "Bash(make build*)"
    - "Bash(tsc*)"

    # Mis commands
    - "Bash(mkdir *)"

  ask:
    # Git - remote/history operations
    - "Bash(git push*)"
    - "Bash(git pull*)"
    - "Bash(git merge *)"
    - "Bash(git rebase *)"

    # Network operations
    - "Bash(curl *)"
    - "Bash(wget *)"
    - "Bash(npm publish*)"
    - "Bash(docker push*)"
    - "Bash(gh *)"

    # Package installation - JS
    - "Bash(npm install*)"
    - "Bash(npm ci*)"
    - "Bash(pnpm install*)"
    - "Bash(pnpm add*)"
    - "Bash(yarn install*)"
    - "Bash(yarn add*)"

    # Package installation - Python
    - "Bash(pip install*)"
    - "Bash(pip3 install*)"
    - "Bash(pipx install*)"
    - "Bash(poetry install*)"
    - "Bash(poetry add*)"
    - "Bash(uv pip install*)"
    - "Bash(uv add*)"

    # Package installation - Ruby
    - "Bash(bundle install*)"
    - "Bash(bundle update*)"
    - "Bash(gem install*)"

    # Package installation - Go/Rust
    - "Bash(cargo install*)"
    - "Bash(go install*)"
    - "Bash(go get*)"

    # System modifications
    - "Bash(brew *)"
    - "Bash(sudo *)"
    - "Bash(chmod *)"
    - "Bash(chown *)"
    - "Bash(launchctl *)"
    - "Bash(defaults *)"

    # Container operations
    - "Bash(docker build*)"
    - "Bash(docker run*)"
    - "Bash(docker compose*)"

  deny:
    # Destructive file operations
    - "Bash(rm -rf *)"
    - "Bash(rm -fr *)"
    - "Bash(rmdir *)"

    # Git - history destruction
    - "Bash(git reset --hard*)"
    - "Bash(git clean -f*)"
    - "Bash(git push --force*)"
    - "Bash(git push -f *)"
    - "Bash(git checkout -- .)"
    - "Bash(git restore .)"

    # Dangerous system commands
    - "Bash(killall *)"
    - "Bash(pkill *)"
    - "Bash(shutdown*)"
    - "Bash(reboot*)"
```

## Rationale

| Category | Decision | Why |
|----------|----------|-----|
| File ops | Allow | Core development activity, reversible via git |
| Git local | Allow | Safe operations, changes stay local |
| Git remote | Ask | Affects shared history, others may pull |
| Tests/lint | Allow | Read-only validation, no side effects |
| Builds | Allow | Local artifacts, safe to regenerate |
| Package install | Ask | Modifies node_modules/venv, potential supply chain |
| Network | Ask | Data egress, external dependencies |
| System | Ask | Affects machine state outside project |
| Destructive | Deny | Irreversible, high blast radius |
