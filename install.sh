#!/usr/bin/env bash
# claude-memory-kit installer.
# Idempotent: safe to run any number of times. It never overwrites your memory
# tree; it only ADDS a fresh skeleton if none exists. It DOES overwrite skill
# files in each detected tool directory, so re-running pushes skill updates.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEMORY_ROOT="${CLAUDE_MEMORY_ROOT:-$HOME/claude-memory}"
BIN_DIR="${HOME}/.local/bin"

log() { printf "\033[1;32m==>\033[0m %s\n" "$*"; }
warn() { printf "\033[1;33m!! \033[0m %s\n" "$*" >&2; }

# -------- 1. Memory tree ---------------------------------------------------
if [[ ! -d "$MEMORY_ROOT" ]]; then
  log "Creating memory tree at $MEMORY_ROOT"
  mkdir -p "$MEMORY_ROOT"
  cp -R "$REPO_ROOT/memory-tree/." "$MEMORY_ROOT/"
else
  log "Memory tree already exists at $MEMORY_ROOT — leaving your content alone."
  # Still ensure the two root-level agent context files exist.
  for f in AGENTS.md CLAUDE.md; do
    if [[ ! -f "$MEMORY_ROOT/$f" && -f "$REPO_ROOT/memory-tree/$f" ]]; then
      cp "$REPO_ROOT/memory-tree/$f" "$MEMORY_ROOT/$f"
      log "  added $f"
    fi
  done
fi

# Substitute the real path into the two agent context files so they mention
# the actual location on this machine (safe: files were just copied in).
for f in "$MEMORY_ROOT/AGENTS.md" "$MEMORY_ROOT/CLAUDE.md"; do
  [[ -f "$f" ]] || continue
  sed -i.bak "s|__MEMORY_ROOT__|$MEMORY_ROOT|g" "$f" && rm -f "$f.bak"
done

# -------- 2. Skill fan-out -------------------------------------------------
log "Fanning out skills to detected agent tools"

fan_out() {
  local dest_dir="$1" style="$2"
  mkdir -p "$dest_dir"
  case "$style" in
    skill-folder)
      for skill in checkpoint restore commit; do
        mkdir -p "$dest_dir/$skill"
        cp "$REPO_ROOT/skills/$skill/SKILL.md" "$dest_dir/$skill/SKILL.md"
      done
      ;;
    flat-md)
      for skill in checkpoint restore commit; do
        cp "$REPO_ROOT/skills/$skill/SKILL.md" "$dest_dir/$skill.md"
      done
      ;;
    cursor-rules)
      for skill in checkpoint restore commit; do
        cp "$REPO_ROOT/skills/$skill/SKILL.md" "$dest_dir/$skill.mdc"
      done
      ;;
    windsurf-rules)
      cat "$REPO_ROOT/adapters/windsurf-header.md" > "$dest_dir/claude-memory.md"
      for skill in checkpoint restore commit; do
        printf '\n\n---\n\n' >> "$dest_dir/claude-memory.md"
        cat "$REPO_ROOT/skills/$skill/SKILL.md" >> "$dest_dir/claude-memory.md"
      done
      ;;
  esac
  log "  $style -> $dest_dir"
}

while IFS='|' read -r dest style; do
  [[ "$dest" =~ ^[[:space:]]*# ]] && continue
  [[ -z "${dest// }" ]] && continue
  dest_expanded="${dest/#\~/$HOME}"
  fan_out "$dest_expanded" "$(echo "$style" | xargs)"
done < "$REPO_ROOT/adapters/tool-registry.txt"

# -------- 3. mem CLI helper ------------------------------------------------
mkdir -p "$BIN_DIR"
cp "$REPO_ROOT/bin/mem" "$BIN_DIR/mem"
chmod +x "$BIN_DIR/mem"
log "Installed 'mem' helper -> $BIN_DIR/mem"

case ":$PATH:" in
  *":$BIN_DIR:"*) : ;;
  *)
    warn "$BIN_DIR is not on your PATH."
    warn "Add this to your shell profile (~/.zshrc or ~/.bashrc):"
    warn "  export PATH=\"\$HOME/.local/bin:\$PATH\""
    ;;
esac

# -------- 4. Environment hint ----------------------------------------------
log "Done."
cat <<EOF

Memory root: $MEMORY_ROOT
Skill CLI:   $BIN_DIR/mem

Try one of these to confirm it works:
  mem restore
  mem list

In an agent that has file tools, type /restore (or paste the skill body).
EOF
