# CLAUDE.md

## What this repo is

A reproducible macOS dev environment with a layer system (personal/work). Two entry points: `run` (orchestrates tool installs via scripts in `runs/`) and `dev-env` (deploys config files from `home/` and `home-work/`).

## Commands

```bash
./run --dry              # Preview full run
./run --dry --work       # Preview with work layer
./run --dry cursor       # Preview single script + deps
./run --work             # Real run, sets sticky layer
./dev-env                # Re-deploy config files only
./dev-env --work         # Re-deploy with work overlay
```

## Directory Structure

- `run` — main orchestrator script
- `dev-env` — config deployment script (also a run script dependency)
- `runs/` — install/setup scripts (personal layer)
- `runs-work/` — work-only install scripts
- `runs/_lib.sh` — shared helpers sourced by all scripts
- `home/` — dotfiles/config deployed to `~` (personal layer)
- `home-work/` — work-layer config overlays (only files that differ)

## Architecture

### Layer system

`--work`/`--personal` flags write to `~/.dev-env-layer` (sticky). `CURRENT_LAYER` env var is exported for child scripts. Dry runs resolve the layer in-memory without touching the file.

When `layer=work`:
- `run` scans `runs-work/*` and namespaces them as `work/<name>` in the dependency graph
- `dev-env` applies personal config first, then overlays specific files from `home-work/` (does NOT replace directories — merges individual files)

### Dependency graph

Scripts declare deps via `# DEPS:` header. `run` does topological sort with cycle detection. The chain is:

`repos` (no deps) → `dev-env` (deps: repos) → everything else (deps: dev-env, and homebrew if they need brew)

All scripts should depend on `dev-env`. Scripts that don't need brew (e.g. `claude`, `nvm`, `macos-defaults`) omit the `homebrew` dep.

### Script conventions

- Source `runs/_lib.sh` for helpers: `execute`, `log_section`, `log_step`, `log_skip`, `log_manual`, `brew_install`, `brew_cask_install`, `clone_or_pull`
- `execute` wraps commands to respect `--dry` mode — always use it for side-effecting commands
- Bare commands (not wrapped in `execute` or `DRY` checks) WILL run during dry runs — avoid this for anything with side effects (the `op vault list` → `op account list` fix was exactly this bug)
- For cask installs, check `/Applications/AppName.app` exists first to avoid errors when the app was installed outside of brew
- Use `cp -p` (preserve permissions) when copying executable scripts
- Work overlay in `dev-env` uses targeted `copy_file` calls, not `copy_dir`, to avoid wiping personal-only files in shared directories

### Config deployment (dev-env script)

`dev-env` has its own layer resolution (reads `CURRENT_LAYER` env var from `run`, or resolves independently when called standalone). It uses `copy_dir` for personal config (replaces subdirs) and `copy_file` for work overlays (merges on top).

The `home-work/` directory contains only files that differ from personal — currently `.gitconfig`, `.claude/settings.json`, and `.local/scripts/tmux-sessionizer`.

### Adding a new run script

1. Create `runs/<name>` (executable, no extension)
2. Add `# DEPS: dev-env` header (add `homebrew` if it needs brew)
3. Source `runs/_lib.sh` at the top
4. Wrap all side-effecting commands in `execute`

### Article saving workflow

`save-article <url>` extracts article content via `readability-cli`, generates summary and tags via `claude -p`, and writes an Obsidian-compatible markdown note to `~/personal/docs/articles/saved/`. A Raycast Script Command wrapper lives in `home/.local/scripts/raycast/save-article.sh`. Raycast script commands directory (`~/.local/scripts/raycast`) must be added manually in Raycast Settings > Extensions > Script Commands.

### Work scripts (runs-work/)

These only run when `CURRENT_LAYER=work`. They can depend on personal scripts (e.g. `postgresql` depends on `homebrew`). Layer-aware personal scripts (like `repos`) check `CURRENT_LAYER` internally rather than being split into separate work scripts.
