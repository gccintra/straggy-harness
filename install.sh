#!/usr/bin/env bash
set -euo pipefail

HARNESS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(git -C "$HARNESS_DIR" rev-parse --show-superproject-working-tree)"

if [[ -z "$PROJECT_DIR" ]]; then
  echo "Este instalador deve ser executado com o harness em um submódulo do projeto consumidor." >&2
  exit 1
fi

link_path() {
  local target="$1"
  local path="$2"

  if [[ -L "$path" && "$(readlink "$path")" == "$target" ]]; then
    return
  fi

  if [[ -e "$path" || -L "$path" ]]; then
    echo "Não alterado: $path já existe. Mova ou remova esse caminho e execute novamente." >&2
    return 1
  fi

  ln -s "$target" "$path"
}

link_path ".agents/runtime/claude" "$PROJECT_DIR/.claude"
link_path ".agents/runtime/codex" "$PROJECT_DIR/.codex"
link_path ".agents/runtime/opencode" "$PROJECT_DIR/.opencode"
link_path ".agents/runtime/claude/mcp.json" "$PROJECT_DIR/.mcp.json"

echo "Regras invariantes do harness vivem em .agents/ENGAGEMENT.md (versionadas, carregadas pelas skills/personas)."
echo "AGENTS.md/CLAUDE.md na raiz são override LOCAL opcional do projeto — crie se precisar; não substituem o ENGAGEMENT.md."
echo "Harness instalado em $PROJECT_DIR"
