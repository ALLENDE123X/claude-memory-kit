---
name: checkpoint
description: Save the current session as a checkpoint to the on-disk memory tree at $CLAUDE_MEMORY_ROOT (default ~/claude-memory). Modes — exhaustive (default, 5–10K words, full digest), --concise (~500 words), --raw (verbatim dump). Writes a .md body + .json sidecar to the active project's checkpoints/ folder (or global) and inserts an index line at the top of MEMORY.md's checkpoint list. Works from any agent (Claude Code, Cursor, Codex, Antigravity, Aider, opencode, Gemini, Windsurf, or a plain terminal via `mem checkpoint`). Resolve the active project from --project, else a .claude-project file in cwd or an ancestor, else the CLAUDE_PROJECT env var, else a MEMORY_PROJECT: <slug> line in the nearest CLAUDE.md or AGENTS.md, else global.
---

# /checkpoint

Save session state to disk so the next `/restore` can pick up cleanly.

## Step 0 — Locate the memory root

Resolve `MEMORY_ROOT` from `CLAUDE_MEMORY_ROOT` env, else `~/claude-memory`, else `~/Documents/claude-memory`. Announce the resolved path.

## Step 1 — Detect access method

Same order as `/restore`:

1. Native file tools (Read/Write/Edit/Bash).
2. Filesystem MCP (`read_file`, `write_file`, `list_directory`, `create_directory`).
3. Shell / Bash tools.
4. The installed `mem` CLI helper — `mem checkpoint --mode <mode> --topic <slug>` accepts the composed content on stdin.

Announce which method you're using.

## Step 2 — Resolve project + mode

**Project:** try in order; stop at first hit:
1. `--project <slug>` argument.
2. `.claude-project` file in cwd or an ancestor.
3. `CLAUDE_PROJECT` env var.
4. `MEMORY_PROJECT: <slug>` line in nearest `CLAUDE.md`.
5. `MEMORY_PROJECT: <slug>` line in nearest `AGENTS.md`.
6. Otherwise: **global**.

`general` or none → global scope: checkpoints dir = `$MEMORY_ROOT/checkpoints/`, index = `$MEMORY_ROOT/MEMORY.md`.
Otherwise → project scope: checkpoints dir = `$MEMORY_ROOT/projects/<slug>/checkpoints/`, index = `$MEMORY_ROOT/projects/<slug>/MEMORY.md`.

If the project dir doesn't exist yet under `projects/`, create it and drop a minimal MEMORY.md before writing the checkpoint.

**Mode:** `--exhaustive` (default), `--concise`, or `--raw`. If more than one is passed, prefer `--raw`, then `--concise`, then exhaustive.

**Validate** the slug matches `^[a-z0-9][a-z0-9-]{0,49}$`; refuse and stop if not.

Announce: "Checkpointing **<slug or global>** in **<mode>** mode (via <method>), project resolved via <source>."

## Step 3 — Compose the checkpoint content

Get the timestamp with **second resolution**: `date '+%Y-%m-%d-%H%M%S'`.

Filename slug: `YYYY-MM-DD-HHMMSS-<topic>` where `<topic>` is a 2–4 word kebab-case summary. Check the file doesn't already exist; if it does, append `-2`, `-3`, etc. before `.md`.

### Frontmatter (all modes)
```yaml
---
project: <slug or "global">
topic: <topic>
created: <ISO 8601 timestamp>
mode: concise | exhaustive | raw
status: complete
next_action: <one sentence — the very specific first thing to do on resume>
---
```

### concise mode (~500 words)
Sections in order:
1. `# Checkpoint: <human topic title>`
2. `## TL;DR` — 3–5 sentences.
3. `## Decisions` — bullets with one-line rationale each.
4. `## Open questions`
5. `## Next steps` — ordered ≤5. First item must be actionable.
6. `## Key references` — 3–8 files/links/people.

### exhaustive mode (default, 5–10K words)
1. `# Checkpoint: <human topic title>`
2. `## TL;DR` — 4–6 sentences.
3. `## Goals`
4. `## Decisions made` — every decision + rationale + rejected alternatives.
5. `## What we did` — chronological narrative.
6. `## Challenges & how we overcame them`
7. `## Files & links discussed`
8. `## People interacted with`
9. `## Tools used`
10. `## Open questions`
11. `## Next steps`
12. `## Anti-patterns / things to avoid`

### raw mode
Full transcript verbatim under `# Raw transcript`. No summarization.

## Step 4 — Write the body

Write `<checkpoints dir>/YYYY-MM-DD-HHMMSS-<topic>.md`.

## Step 5 — Write the JSON sidecar

Write `<checkpoints dir>/YYYY-MM-DD-HHMMSS-<topic>.json`:
```json
{
  "project": "<slug or global>",
  "topic": "<topic>",
  "created": "<ISO 8601>",
  "mode": "concise|exhaustive|raw",
  "status": "complete",
  "tldr": "<one or two sentences>",
  "next_action": "<verbatim>",
  "decisions_count": null,
  "people_interacted_with": [],
  "files_referenced": [],
  "filename": "YYYY-MM-DD-HHMMSS-<topic>.md"
}
```

## Step 6 — Update the MEMORY.md index

Read the scope's `MEMORY.md`. Find or create a `## Checkpoints` section. Insert at the **top** of the list (newest first):
```
- [YYYY-MM-DD HHMMSS — <Topic Title>](checkpoints/<filename>.md) — [<mode>] <one-sentence TL;DR>
```

Never write checkpoint body content into MEMORY.md — index lines only.

## Step 7 — Confirm

```
✓ Checkpoint saved [<mode>]
  Project:      <slug or "global">
  Body:         <full path to .md>
  Sidecar:      <full path to .json>
  Indexed in:   <path to MEMORY.md>
  Next action:  <the next_action line>
```

## Rules

- Exhaustive is the default. Use `--concise` for a cheap continuity save.
- Filename uses second resolution + collision suffix — never overwrite.
- Timestamps zero-padded so filenames sort chronologically.
- Never write checkpoint content into MEMORY.md — index lines only.
