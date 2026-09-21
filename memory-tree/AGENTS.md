# Claude Memory Protocol — AGENTS.md

This file is read automatically by many coding agents (Codex, opencode, some
Cursor configurations, generic AGENTS.md-aware tools). It tells every agent
that opens a repo under this tree how the persistent-memory workflow works.

**Memory root:** `__MEMORY_ROOT__`

## Two habits, every session

1. **On the first user message of a new session**, run `/restore` (or the
   equivalent flat-file skill in this agent's prompt directory, or the
   fallback `mem restore` CLI). This loads global facts, the active
   project's memory, and a "where you left off" summary from the newest
   checkpoint sidecar.

2. **When the session produces meaningful work** and the user signals
   wrap-up (says thanks/bye/done, or the conversation is clearly complete),
   run `/checkpoint` (or `mem checkpoint`). Default mode is exhaustive; use
   `--concise` for a quick continuity save.

## How to find the active project

Try in order, stop at the first hit:
1. `--project <slug>` argument.
2. A `.claude-project` file in the current working directory or any ancestor.
3. `CLAUDE_PROJECT` environment variable.
4. A `MEMORY_PROJECT: <slug>` line anywhere in the nearest CLAUDE.md.
5. A `MEMORY_PROJECT: <slug>` line anywhere in the nearest AGENTS.md.
6. Otherwise: `global`.

## Skip auto-memory when

- Quick one-off question with no state change.
- User explicitly says not to save.
- No meaningful decisions or new context were produced.

## Manual overrides

- `/checkpoint` — full manual checkpoint, exhaustive default.
- `/checkpoint --concise` — ~500-word summary.
- `/restore` — full manual restore.
- `/restore --concise` — index-only restore (cheap).
- `/restore --all` — every non-raw checkpoint body loaded.
- `/commit` — commit a reference doc (manual, transcript) to the tree.

## File conventions

- Slugs are kebab-case.
- Checkpoints are `.md` + `.json` sidecar pairs, named
  `YYYY-MM-DD-HHMMSS-<topic>` so they sort chronologically.
- MEMORY.md files hold only index lines — never checkpoint body content.
- Cross-project facts live at the memory root. Every `/restore` reads them.
- Project-specific facts live in `projects/<slug>/`. Read only when that
  project is active.
