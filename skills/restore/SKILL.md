---
name: restore
description: Reload context from the on-disk memory tree at $CLAUDE_MEMORY_ROOT (default ~/claude-memory). Reads global MEMORY.md + cross-project facts, the active project's MEMORY.md + sub-files, scans checkpoint JSON sidecars, loads bodies mode-aware (concise newest-10 in full, exhaustive newest-1 in full, raw opt-in), and synthesizes a "where you left off" summary that leads with the next action. Works from any agent (Claude Code, Cursor, Codex, Antigravity, Aider, opencode, Gemini, Windsurf, or a plain terminal via `mem restore`). Resolve the active project from --project, else a .claude-project file in cwd or an ancestor, else the CLAUDE_PROJECT env var, else a MEMORY_PROJECT: <slug> line in the nearest CLAUDE.md or AGENTS.md, else global.
---

# /restore

Reload context from the memory tree.

## Step 0 — Locate the memory root

Resolve `MEMORY_ROOT` in this order, use the first that produces a real directory:

1. The `CLAUDE_MEMORY_ROOT` environment variable.
2. `~/claude-memory` (the installer default).
3. `~/Documents/claude-memory` (legacy default).

Announce the resolved path. If none exist, tell the user to run the installer and stop.

## Step 1 — Detect access method

Pick the first method whose tools are actually available in this agent:

1. **Native file tools** — a `Read`, `Write`, `Edit`, `Glob`, `Grep` built into the coding-agent (Claude Code, Cursor, Antigravity, Codex, opencode…). Use these directly against `MEMORY_ROOT`.
2. **Filesystem MCP** — `read_file` / `read_text_file` / `list_directory` / `directory_tree`. Point at `MEMORY_ROOT`.
3. **Shell / Bash** — plain POSIX commands (`cat`, `find`, `ls`, `jq`) against `MEMORY_ROOT`.
4. **`mem` CLI** — the installed helper. `mem restore` prints the full "where you left off" summary; parse and reuse its output.

Announce which method you're using.

## Step 2 — Resolve the active project (announce loudly)

Try each in order; stop at the first that resolves:

1. Explicit `--project <slug>` argument.
2. A `.claude-project` file in the current working directory or any ancestor up to `$HOME` — its trimmed contents are the slug.
3. `CLAUDE_PROJECT` environment variable.
4. A `MEMORY_PROJECT: <slug>` line anywhere in the nearest `CLAUDE.md` (walk up from cwd).
5. A `MEMORY_PROJECT: <slug>` line anywhere in the nearest `AGENTS.md`.
6. Otherwise: **global**.

Say the resolved slug and the source (arg / .claude-project / env / CLAUDE.md / AGENTS.md / none). Silent misroutes are the top failure mode of this system — surface detection prominently.

## Step 3 — Read global memory

- Read `$MEMORY_ROOT/MEMORY.md`.
- Read each cross-project fact file it links from its root (`style-preferences.md`, etc.). These are small; read them all unless `--concise` is passed.

## Step 4 — Read project memory (skip if global)

- Read `$MEMORY_ROOT/projects/<slug>/MEMORY.md`.
- List `$MEMORY_ROOT/projects/<slug>/` and read every `.md` sub-file except those inside `checkpoints/` (that's the working-set memory, not the checkpoint log).

`--concise`: skip the sub-file reads. The project MEMORY.md's one-liners are the table of contents; open a specific sub-file only when the conversation actually needs it.

## Step 5 — Scan checkpoint sidecars (cheap)

- List `$MEMORY_ROOT/projects/<slug>/checkpoints/` (or `$MEMORY_ROOT/checkpoints/` for global).
- Read each `.json` sidecar (filenames sort chronologically; newest first). Pull `topic`, `created`, `tldr`, `next_action`, `mode`, `decisions_count`.

If `--include-global-checkpoints`, also scan the global `checkpoints/` dir and tag those `(global)`.

## Step 6 — Load bodies (mode-aware, capped)

- **concise:** read the newest **10** `.md` bodies in full. Older concise checkpoints contribute only their sidecar tldr + next_action.
- **exhaustive:** read the newest **1** body in full. Older exhaustive checkpoints contribute sidecar only.
- **raw:** skip entirely unless `--include-raw`.
- `--all`: read every non-raw body in full (no caps).
- Skip any checkpoint whose `status` is `abandoned` or `superseded`.

## Step 7 — Synthesize "where you left off"

Lead with the next action:

```markdown
## Where you left off — <project title or "Global">

**Last checkpoint:** <topic> (<YYYY-MM-DD HHMMSS>)
**→ Next:** <next_action from latest checkpoint, verbatim>

**Detected project:** <slug or "none"> (source: <arg | .claude-project | env | CLAUDE.md | AGENTS.md | none>)
**Access method:** <native | fs-mcp | shell | mem-cli>
**Memory root:** <resolved path>

### Project state
<2–3 sentences from MEMORY.md + sub-files>

### Recent decisions
- <newest first>

### Open threads
- <unresolved question / blocker>

### Other next steps
- <secondary, if still open>

### Key references touched recently
- <files, URLs>

### Checkpoint history
- <date> [<mode>] <topic> — TL;DR: <one sentence>   (← FULL BODY LOADED / TL;DR only)
(N checkpoints; loaded: X concise + Y exhaustive; skipped: Z raw)
```

## Step 8 — Offer the next action

Ask: "Pick up on the next step, or work on something else?" Then wait.

## Rules

- Read-only. Never modify memory files during /restore.
- Lead with the answer (next action in the first two lines).
- Announce the resolved project + source + access method + memory root prominently.
- Skip abandoned/superseded checkpoints.
