# dev-env

Reproducible macOS development environment with layer-aware personal/work configuration.

## Quick start

```bash
# Set up everything (personal layer)
./run

# Set up everything (work layer — includes work repos, configs, and tools)
./run --work

# Run a single script (+ its dependencies)
./run cursor

# Re-deploy config files only (e.g. after editing dotfiles)
./dev-env
./dev-env --work

# Preview what would happen without making changes
./run --dry
./run --dry --work
./run --dry cursor
```

The `--work` and `--personal` flags are sticky — they write to `~/.dev-env-layer` so subsequent runs remember the layer. `--dry` does not modify the layer file.

## Layers

The layer system prevents work config from overwriting personal config (and vice versa) when running individual scripts.

| Command | Layer file | Result |
|---|---|---|
| `./run` (no file) | unchanged | personal only |
| `./run` (file=work) | unchanged | personal + work |
| `./run --work` | creates | personal + work |
| `./run --personal` | removes | personal only |

When `layer=work`, the `dev-env` script applies personal config first, then overlays work-specific config on top (git identity, claude settings, tmux-sessionizer, ready-tmux scripts).

## What's installed

Scripts run in dependency order. `dev-env` depends on `repos`; all other scripts depend on `dev-env` (and `homebrew` if they need brew).

| Script | What it does |
|---|---|
| **repos** | Clones personal repos (`zmk-config-hsv`, `qmk_firmware`); work repos when layer=work (`tmrw-core-api`, `tmrw-protocols`, `tmrw-client`) |
| **dev-env** | Deploys all config files from `home/` and work overlays from `home-work/` |
| **homebrew** | Installs Homebrew and configures shell profile |
| **1password** | 1Password app + CLI, verifies auth |
| **claude** | Claude Code CLI, clones claude-config, symlinks agents/skills |
| **cursor** | Cursor IDE + 15 extensions |
| **fonts** | Nerd Fonts (Fira Code, Iosevka Term Slab, Terminess) |
| **gh** | GitHub CLI + auth |
| **httpie** | HTTPie CLI + Desktop app |
| **macos-defaults** | Keyboard repeat, Dock, Finder, and text input preferences |
| **neovim** | Neovim v0.11.6 from source + ripgrep, fd, tree-sitter |
| **nvm** | Node Version Manager |
| **orbstack** | OrbStack (containers/VMs) |
| **raycast** | Raycast launcher + config import |
| **shell** | FZF, bat, parallel, shellcheck, Starship prompt |
| **slack** | Slack app |
| **terminal** | Ghostty terminal, tmux, Tmux Plugin Manager |
| **work/postgresql** | PostgreSQL 17 (work layer only) |

### Config files

Config lives in `home/` (personal, always deployed) and `home-work/` (work overlay, deployed when layer=work). The work overlay merges specific files on top of personal config rather than replacing directories.

**Shell** (`home/.zshrc`) — FZF integration, NVM with auto-use for `.nvmrc`, 70+ git aliases, npm aliases, general aliases (cat=bat, find=fd), Homebrew completions, Starship prompt init, `Ctrl-f` for tmux-sessionizer. See [Zsh aliases](#zsh-aliases).

**Git** (`home/.gitconfig`) — User identity, auto-setup remote, fetch prune. Work overlay changes email to work address.

**Neovim** (`home/.config/nvim/`) — Full IDE setup with LSP, completion, formatting, linting, and 20+ plugins. See [Neovim deep dive](#neovim).

**Tmux** (`home/.config/tmux/`) — Vi keybinds, mouse support, passthrough enabled, Monokai Pro theme, sessionizer integration. See [Tmux sessionizer](#tmux-sessionizer).

**Ghostty** (`home/.config/ghostty/`) — Fira Code Nerd Font, Monokai Pro theme, auto-update enabled.

**Starship** (`home/.config/starship.toml`) — Monokai Dark palette, directory truncation, git branch/status, language version indicators.

**Cursor** (`home/.config/cursor/`) — Bearded Monokai Terra theme, format on save, ESLint integration.

**Claude Code** (`home/.claude/`) — Status line with git/model/context info, voice enabled, plugins. Work overlay adds TMRW-specific plugins and marketplace.

**Tmux scripts** (`home/.local/scripts/`) — `tmux-sessionizer` (FZF session picker), `tmux-init` (layout loader), `tmux-cleanup` (kill all sessions). Per-directory `.ready-tmux` scripts define custom layouts. See [Tmux sessionizer](#tmux-sessionizer).

## Adding a new script

Create a file in `runs/` (or `runs-work/` for work-only scripts):

```bash
#!/usr/bin/env bash
# DEPS: dev-env, homebrew
source "$(dirname "${BASH_SOURCE[0]:-$0}")/_lib.sh"

log_section "My Tool"
brew_install my-tool
```

**Conventions:**
- `# DEPS:` header declares dependencies. Use `dev-env` to ensure config is deployed first; add `homebrew` if you need brew.
- Source `_lib.sh` for helpers: `log_section`, `log_step`, `log_skip`, `log_manual`, `execute`, `brew_install`, `brew_cask_install`, `clone_or_pull`.
- `execute` wraps commands to respect `--dry` mode. Use `log_manual` for steps that can't be automated.
- For app installs, check if already present before running brew (e.g. `if [[ -d "/Applications/MyApp.app" ]]`).
- Work-only scripts go in `runs-work/` and are namespaced as `work/<name>` in the dependency graph.

## Deep dives

### Neovim

Built from source (v0.11.6) with a full plugin setup via lazy.nvim:

**Core:** telescope (fuzzy finder), which-key (keybind discovery), gitsigns (git hunks/blame), guess-indent, blink.cmp (completion with LSP + Copilot)

**LSP:** vtsls (TypeScript), eslint (with auto-fix on save), tailwindcss, lua_ls. Managed by mason.nvim.

**Formatting:** conform.nvim with prettierd/prettier (JS/TS/JSON/YAML/CSS/HTML/GraphQL) and stylua (Lua). Format on save.

**Linting:** nvim-lint with shellcheck for bash/sh.

**Testing:** neotest with vitest and jest adapters. `<leader>tn` (nearest), `<leader>tf` (file), `<leader>ts` (summary).

**Navigation:** neo-tree (file explorer, `\`), telescope for files/grep/LSP symbols, trouble.nvim for diagnostics.

**Extras:** nvim-ts-autotag (HTML/JSX), package-info.nvim (inline npm versions), tsc.nvim (TypeScript type checker), copilot via blink-copilot, DAP debugging.

### Tmux sessionizer

`Ctrl-f` opens FZF with active tmux sessions and `~/personal` subdirectories. Selecting one switches to the session or creates it. New sessions run a `.ready-tmux` script from the project directory (falling back to `~/.ready-tmux`) which sets up the window/pane layout — typically nvim in the top pane with claude in the bottom-right.

Work layouts (`tmrw/*.ready-tmux`) create multi-window setups with dev, run, and service windows for each TMRW repo.

To add a custom layout to any repo, create a `.ready-tmux` script in the project root:

```bash
#!/usr/bin/env bash
session=$1
dir=$2

# Rename the first window and open nvim
tmux rename-window -t "=$session:0" "dev"
pane=$(tmux list-panes -t "=$session:0" -F '#{pane_id}' | head -1)
tmux send-keys -t "$pane" "nvim ." Enter

# Add a second window for running commands
tmux new-window -t "=$session" -n "run" -c "$dir"
tmux select-window -t "=$session:dev"
```

Add `.ready-tmux` to the repo's `.git/info/exclude` to keep it out of git. To make it portable, store the script in this repo (e.g. `tmrw/my-repo.ready-tmux`) and add a copy step to the `dev-env` script — see the TMRW ready-tmux section in `dev-env` for the pattern.

### Zsh aliases

**Git (70+):** `g`=git, `ga`=add, `gco`=checkout, `gcb`=checkout -b, `gd`=diff, `gdc`=diff --cached, `gl`=pull, `gp`=push, `grb`=rebase, `gst`=status, `gcam`=commit -am, `gstaa`=stash apply, and many more. All support tab completion via git-aware expansion.

**npm:** `npmi`=install, `npmS`=save, `npmD`=save-dev, `npmt`=test, `npmR`=run, and others.

**General:** `cat`=bat, `find`=fd, `ll`=ls -la, `..`=cd .., `...`=cd ../..
