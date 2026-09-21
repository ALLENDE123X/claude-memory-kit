# How it works

Three things, in order of importance:

## 1. The tree is plain markdown

Everything lives at `$CLAUDE_MEMORY_ROOT` (default `~/claude-memory/`) as regular `.md` and `.json` files. There's no server, no daemon, no database, no MCP server that has to be running. You can `cat`, `grep`, `git`, `rsync`, `cp` any of it. If every tool in this kit disappears tomorrow, your memory is still yours.

The only conventions that matter:

- **Fact files** at the memory root or under `projects/<slug>/` — one topic per file, markdown, YAML frontmatter with `name` / `description` / `type` on top.
- **Checkpoints** in `checkpoints/` folders — `.md` body + matching `.json` sidecar, named `YYYY-MM-DD-HHMMSS-<topic>` so filenames sort chronologically.
- **MEMORY.md** at each scope holds only *index lines* — links to fact files and one-liners for each checkpoint. Never checkpoint body content.

## 2. The skills are portable prompts

Each of `/checkpoint`, `/restore`, `/commit` is a single markdown file with a YAML header. The installer drops that file into every place any of your agents looks for prompts, skills, or rules:

| Agent | Path | Format |
|---|---|---|
| Claude Code | `~/.claude/skills/<name>/SKILL.md` | folder-per-skill |
| Cursor | `~/.cursor/rules/<name>.mdc` | flat |
| Codex CLI | `~/.codex/prompts/<name>.md` | flat |
| Antigravity | `~/.antigravity/skills/<name>/SKILL.md` + AGENTS.md | folder + agents-md |
| opencode | `~/.config/opencode/prompts/<name>.md` | flat |
| Gemini CLI | `~/.gemini/prompts/<name>.md` | flat |
| Aider | `~/.aider.conf.d/prompts/<name>.md` | flat |
| Windsurf | `~/.windsurf/rules/claude-memory.md` | one bundled file |

Because the skill is instructions in English (with a bit of YAML frontmatter each tool recognizes), it works in any agent that can read a system prompt. The skill tells the agent to detect its own environment — native Read/Write vs filesystem MCP vs shell — and act accordingly.

## 3. The `mem` CLI is the escape hatch

For any terminal without agent tooling — a raw ssh session, cmux, a scripted cron job — `mem` gives you the same operations:

```bash
mem restore                                    # show where you left off
echo "TL;DR ... Next: ..." | mem checkpoint --mode concise --topic hotfix
mem list --project my-project
mem tree
```

It's ~200 lines of POSIX shell + jq. Nothing else.

---

## Session lifecycle

```
Agent session starts
      │
      ▼
  /restore   ── reads global + project MEMORY.md, cross-project facts,
      │        checkpoint sidecars, loads newest bodies mode-aware
      ▼
  work, decisions, tool calls, files touched
      │
      ▼
  /checkpoint ── writes .md + .json to checkpoints/, updates MEMORY.md
      │        with a one-line index entry
      ▼
Session ends
```

Next session picks up from the sidecars — cheap to scan — and only pays for a body read when it's the newest or when you ask for `--all`.

---

## Why not a hosted memory service?

Because you already have the perfect substrate: your filesystem, git, and any sync tool you like. Hosted memory services (mem0, Zep, Letta, SuperMemory) trade portability for semantic search you may or may not need. If you do decide you need vector retrieval later, you can bolt it on top of this tree — the markdown files are the source of truth either way.

## Sync across machines

Any of these work; pick one:

- **git** — turn `~/claude-memory/` into a repo, commit and push whenever. Best for solo use.
- **iCloud / Dropbox / OneDrive** — put the tree in a synced folder, set `CLAUDE_MEMORY_ROOT` to point at it.
- **Syncthing** — for peer-to-peer sync without a cloud.
- **rsync in a cron** — for the paranoid.

The tree is portable text; whichever sync you're already using for docs will work for this too.
