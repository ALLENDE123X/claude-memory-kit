# Setup — the short version

## Prereqs

- `bash`, `git`, `jq`, `date` — standard on macOS and every Linux distro. WSL works too.
- One or more coding agents installed (any combination; the installer detects them all and configures each):
  - Claude Code, Cursor, Codex CLI, Antigravity, opencode, Aider, Gemini CLI, Windsurf, cmux, plain terminal.

## Install

```bash
git clone https://github.com/ALLENDE123X/claude-memory-kit.git
cd claude-memory-kit
bash install.sh
```

## Verify

```bash
mem where       # prints the memory root
mem restore     # prints "(no checkpoints yet — clean slate)"
```

In any agent, type:

```
/restore
```

You should get a "where you left off" summary — empty on first run.

## First real checkpoint

Work on something, then when you're done:

```
/checkpoint
```

The agent writes a `.md` body + `.json` sidecar into `~/claude-memory/checkpoints/` (global) or `~/claude-memory/projects/<slug>/checkpoints/` (project-scoped), and updates the relevant MEMORY.md index.

## Setting an active project

Two ways:

1. **Per-directory** — drop a file called `.claude-project` at the repo root; the only content is the slug:

   ```bash
   echo "my-project" > .claude-project
   ```

2. **Per-shell** — export it:

   ```bash
   export CLAUDE_PROJECT="my-project"
   ```

Now any `/restore` or `/checkpoint` from that shell (or that directory) will scope to that project.

## Moving the tree elsewhere

Set `CLAUDE_MEMORY_ROOT` before installing:

```bash
export CLAUDE_MEMORY_ROOT="$HOME/Dropbox/claude-memory"
bash install.sh
```

The installer copies the skeleton to that path and every skill uses it going forward. Put it in a synced folder (iCloud, Dropbox, Syncthing, git repo) if you want cross-machine sync.

## Uninstall

The installer only writes to:
- `$CLAUDE_MEMORY_ROOT` (default `~/claude-memory/`)
- `~/.local/bin/mem`
- The tool skill directories listed in `adapters/tool-registry.txt`

Delete those to remove everything. Your memory content stays where you put it.
