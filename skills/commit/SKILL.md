---
name: commit
description: Commit a physical or standalone reference document (instruction manual, warranty card, spec sheet, assembly guide, recipe card, meeting transcript) to the on-disk memory tree at $CLAUDE_MEMORY_ROOT (default ~/claude-memory), so the source (paper copy, standalone file) can be discarded. Transcribes every page in full (never a summary), writes it to reference/ (or projects/<slug>/reference/ if scoped), and inserts an index line into the relevant MEMORY.md. Works from any agent with file tools or shell access. Trigger on "/commit", "commit this to memory", "index this manual", or when the user uploads photos of a document and says they don't want to keep the paper copy.
---

# /commit

Turn a document (photographed pages, an attached file, or a pasted transcript) into a permanent, full-text reference file in the memory tree.

## Step 0 — Locate the memory root

Resolve `MEMORY_ROOT` from `CLAUDE_MEMORY_ROOT` env, else `~/claude-memory`, else `~/Documents/claude-memory`. Announce it.

## Step 1 — Detect access method

1. Native file tools (Read/Write/Edit/Bash) — vision-capable agents can also open the photo attachments directly.
2. Filesystem MCP.
3. Shell / Bash.
4. `mem commit --scope <slug|global> --slug <name>` accepting the transcription on stdin.

Announce which you're using.

## Step 2 — Resolve scope

- `--project <slug>` → project scope, reference dir = `$MEMORY_ROOT/projects/<slug>/reference/`.
- Otherwise → global scope, reference dir = `$MEMORY_ROOT/reference/`.

Announce: "Committing to **<slug or global>** reference (via <method>)."

## Step 3 — Transcribe in full

Read every page provided, in page order. Transcribe the **complete** content — a lossy summary defeats the purpose:
- Every spec/number in tables, exactly as printed.
- Every safety warning, in full.
- Every step of any instructions/operation sections.
- Diagram labels and callouts, described in words.
- Manufacturer, contact info, warranty/support details.
- Blurry or illegible passages: say so explicitly rather than guessing.

For non-photo sources (attached PDF, pasted transcript), transcribe the equivalent complete content — no compression.

## Step 4 — Write the reference file

Slug the document title (kebab-case; include a model number if present, e.g. `pulituo-drill-dc7212-manual`). Write to `<reference dir>/<slug>.md`:

```
---
name: <slug>
description: <one-line what this document is>
type: reference
source: <"photographed document (N pages)" | "attached PDF" | ...>
committed: <ISO 8601 date>
---

# <Document Title>

<full transcription, organized by the document's own sections/pages>
```

## Step 5 — Update the MEMORY.md index in place

Read the scope's current `MEMORY.md`. Find or create a `## Reference documents` section. Insert a new line at the **top** of that list (newest first):

```
- [<Document Title>](reference/<slug>.md) — <one-sentence description>
```

Never create a duplicate MEMORY.md — always read then write the same file.

## Step 6 — Confirm

```
✓ Committed to memory
  Scope:    <slug or "global">
  File:     <full path>
  Indexed:  <path to MEMORY.md>
```

## Rules

- Full transcription only. A summary is not "a living version of the document."
- Never silently drop a safety warning, spec, or number.
- If pages are missing or unreadable, say so — don't fill gaps from assumption.
- Never overwrite an existing reference file without asking — collision → append `-2`, `-3`, etc.
