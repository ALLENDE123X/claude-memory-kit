# Claude Memory Protocol — CLAUDE.md

Alias of AGENTS.md for Claude Code, which reads CLAUDE.md automatically at
every level of the directory tree. See AGENTS.md in the same folder for the
full protocol.

**Memory root:** `__MEMORY_ROOT__`

MEMORY_PROJECT: general

## TL;DR

- On session start: run `/restore` (or `mem restore` in a plain shell).
- On session end: run `/checkpoint` (or `mem checkpoint`).
- Active project detection: `.claude-project` file → `CLAUDE_PROJECT` env →
  the `MEMORY_PROJECT:` line above → `global`.
- Full protocol: `AGENTS.md` alongside this file.
