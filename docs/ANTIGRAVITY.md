# Using this in Antigravity

Antigravity doesn't have a registered slash-command directory the way Claude Code does. Its native discovery mechanism is **AGENTS.md** — the agent walks up the directory tree looking for that file when it starts working, and treats it as system context.

So in Antigravity, the trigger is natural language, not a literal `/checkpoint`. Type any of these in the chat panel:

- **"checkpoint this session"** or **"save this session"** or **"run checkpoint"**
- **"restore where we left off"** or **"pick up where we left off"** or **"run restore"**
- **"commit this to memory"** (for a reference doc)

Because the installer drops `AGENTS.md` at your memory root, and because Antigravity's agent reads it, the agent knows the protocol and does the same work it would on `/checkpoint` in Claude Code — writes the `.md` body + `.json` sidecar, updates the MEMORY.md index.

## Getting per-project scoping to work

Antigravity opens repos, not the memory root directly. So for the agent to find `AGENTS.md`, drop a **pointer AGENTS.md** at the root of any repo you work in. This one-liner does that:

```bash
cat > AGENTS.md <<'EOF'
This repo participates in the claude-memory protocol. See ~/claude-memory/AGENTS.md
for the full checkpoint/restore rules. On session start, restore context.
On session end that produced meaningful work, save a checkpoint.
EOF
echo "my-project-slug" > .claude-project
```

Now when Antigravity opens the repo:
- It reads `AGENTS.md` at the repo root → learns the protocol.
- The skills detect `.claude-project` → scope to `my-project-slug`.
- The agent writes checkpoints into `~/claude-memory/projects/my-project-slug/checkpoints/`.

## Muscle-memory alternative — the `mem` CLI in the Antigravity terminal

Every Antigravity workspace has a terminal pane. In it:

```bash
mem restore                     # print where you left off
mem checkpoint --mode concise --topic fix-deploy <<EOF
TL;DR: fixed the flaky test.
Next: rerun CI, verify green.
EOF
```

You can alias these in your shell profile if you want:

```bash
alias c='mem checkpoint'
alias r='mem restore'
```

This route bypasses the agent entirely — deterministic, always works, no natural-language dance.

## Why not exact `/checkpoint`?

Because Antigravity's slash-command surface for user-registered commands is still moving. If Google adds a stable `~/.antigravity/skills/<name>/SKILL.md` convention with a `/<name>` trigger, the installer already drops the files there — you'll just need to reload Antigravity and the slash command will start working. Nothing else needs to change.
