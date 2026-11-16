#!/usr/bin/env bash
# Instala a skill senior-review.
#   ./scripts/install.sh            -> instalação global (Claude Code, Codex e .agents)
#   ./scripts/install.sh <projeto>  -> instalação local em um repositório
#   ./scripts/install.sh --sync     -> sincroniza as cópias versionadas deste repositório
set -euo pipefail

SKILL="senior-review"
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SRC="$ROOT/$SKILL"

copy_to() {
  local dest="$1/$SKILL"
  rm -rf "$dest"
  mkdir -p "$dest"
  cp -R "$SRC/." "$dest/"
  echo "✔ $dest"
}

case "${1:-}" in
  --sync)
    for dir in .claude .codex .agents; do copy_to "$ROOT/$dir/skills"; done
    ;;
  "")
    for dir in "$HOME/.claude/skills" "${CODEX_HOME:-$HOME/.codex}/skills" "$HOME/.agents/skills"; do
      copy_to "$dir"
    done
    ;;
  *)
    target="$(cd "$1" && pwd)"
    for dir in .claude .codex .agents; do copy_to "$target/$dir/skills"; done
    ;;
esac
