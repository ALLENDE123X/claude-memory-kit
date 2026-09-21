# claude-memory-kit

A portable, cross-tool persistent memory system for coding agents. Works with **Claude Code, Cursor, Codex, Antigravity, Aider, Gemini CLI, opencode, Windsurf, cmux** — and any generic terminal — regardless of whether you access them through their desktop apps or a raw shell.

Everything is plain markdown on disk. No server, no database, no lock-in. The agent reads/writes the tree with whatever file tools it has (native, MCP filesystem, or shell).

---

## What this is

Three habits every session, backed by one folder:

1. **`/restore`** at the start — the agent loads global facts, the active project's memory, and a synthesized "where you left off" summary from checkpoint sidecars.
2. **`/checkpoint`** at the end — the agent saves a `.md` body + `.json` sidecar of the session and updates the project index.
3. **`/commit`** whenever a durable reference document (manual, spec, transcript) needs to live in the tree.

The tree lives at `~/claude-memory/` by default. You can point it anywhere with `CLAUDE_MEMORY_ROOT`.

---

## Quick install (any Unix — macOS, Linux, WSL)

```bash
git clone https://github.com/ALLENDE123X/claude-memory-kit.git
cd claude-memory-kit
bash install.sh
```

The installer:

1. Copies `memory-tree/` to `~/claude-memory/` (or `$CLAUDE_MEMORY_ROOT` if set). If a tree already exists there it's left alone — install is idempotent.
2. Copies each skill in `skills/` to **every** agent-tool skill directory it detects on your machine:
   - `~/.claude/skills/` (Claude Code)
   - `~/.cursor/skills/` and workspace `.cursor/rules/`
   - `~/.codex/prompts/` (Codex CLI)
   - `~/.antigravity/skills/`
   - `~/.config/opencode/prompts/`
   - `~/.gemini/prompts/`
   - `~/.aider.conf.d/prompts/`
   - `~/.windsurf/rules/`
   - Anywhere else listed in `adapters/tool-registry.txt`
3. Puts a helper script `mem` on `$PATH` (in `~/.local/bin/`) so any terminal without agent tooling can still read and write checkpoints.
4. Writes an `AGENTS.md` and `CLAUDE.md` at the memory root so agents that read root-level context files pick up the protocol automatically.

Re-run `bash install.sh` any time to push updated skills out to newly installed tools.

---

## Folder shape

```
~/claude-memory/
├── AGENTS.md               # protocol summary (all-tool convention)
├── CLAUDE.md               # same, aliased for Claude Code
├── MEMORY.md               # global registry + cross-project fact links
├── style-preferences.md    # your cross-project fact files
├── checkpoints/            # global-scope checkpoints
├── archive/
└── projects/
    └── <slug>/
        ├── MEMORY.md       # project index + checkpoint list
        ├── <fact>.md       # working-set fact files
        └── checkpoints/
            ├── YYYY-MM-DD-HHMMSS-<topic>.md
            └── YYYY-MM-DD-HHMMSS-<topic>.json
```

The **only** file convention that matters: checkpoints are `.md` bodies paired with `.json` sidecars, named `YYYY-MM-DD-HHMMSS-<topic>` so they sort chronologically. Everything else is markdown you can read yourself.

---

## How each tool picks up the skills

| Tool | Skill location | How to invoke |
|---|---|---|
| Claude Code | `~/.claude/skills/{checkpoint,restore,commit}/SKILL.md` | `/checkpoint`, `/restore`, `/commit` |
| Cursor | `~/.cursor/skills/` + `~/.cursor/rules/*.mdc` | `@memory checkpoint` or paste the skill body |
| Codex CLI | `~/.codex/prompts/*.md` | `/checkpoint` |
| Antigravity | AGENTS.md-based — say "checkpoint" or "restore" in chat | (see docs/ANTIGRAVITY.md) |
| opencode | `~/.config/opencode/prompts/` | `/checkpoint` |
| Aider | `~/.aider.conf.d/prompts/` | `/read prompts/checkpoint.md` then run |
| Gemini CLI | `~/.gemini/prompts/` | `!checkpoint` |
| Windsurf | `~/.windsurf/rules/` | Cascade auto-attaches |
| Any terminal / cmux | `mem` CLI helper | `mem checkpoint`, `mem restore`, `mem commit` |

If a tool isn't in the list, drop `skills/*/SKILL.md` into whatever directory it uses for custom prompts/skills/rules and add it to `adapters/tool-registry.txt` so the installer picks it up next time.

---

## The universal contract

Every skill is written **environment-detecting**. In order, it tries:

1. Native file tools (Claude Code's Read/Write/Edit, Cursor's file API, etc.)
2. MCP filesystem tools (`read_file`, `write_file`, `list_directory`)
3. Shell / Bash tools
4. Falling back to the `mem` CLI helper (a small POSIX shell wrapper — no runtime deps beyond `bash`, `jq`, and `date`)

Because the tree is plain markdown, **any** agent that can read and write files can participate. Nothing is proprietary to any one product.

---

## For your brother — the one-liner

```bash
git clone https://github.com/ALLENDE123X/claude-memory-kit.git && cd claude-memory-kit && bash install.sh
```

Then, in whichever tool he uses first, type `/restore` (or `mem restore` in a plain shell). The tree is empty, so it'll say "clean slate" — that's the confirmation the wiring worked.

From then on: `/checkpoint` at the end of a session, `/restore` at the start of the next one.

---

## Configuration

Set these in your shell profile if you want to override defaults:

```bash
export CLAUDE_MEMORY_ROOT="$HOME/claude-memory"   # where the tree lives
export CLAUDE_PROJECT="my-project-slug"           # active project (or use .claude-project marker)
```

Every project directory you `cd` into can also carry a `.claude-project` file whose only content is the slug — the skills read that automatically.

---

## License

MIT. Do whatever you want.
