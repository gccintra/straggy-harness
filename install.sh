#!/usr/bin/env bash
set -euo pipefail

HARNESS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# O harness mora em <projeto>/.agents/ — como submódulo registrado ou como clone
# local (o projeto pode ignorar .agents/ no Git). Nos dois casos, a raiz do projeto
# é o diretório pai; não dá pra depender de --show-superproject-working-tree, que
# vem vazio quando o clone não está no índice do projeto.
PROJECT_DIR="$(cd "$HARNESS_DIR/.." && pwd)"

if [[ ! -d "$PROJECT_DIR/.git" ]]; then
  echo "Esperava a raiz Git do projeto em $PROJECT_DIR — o harness deve ficar em <projeto>/.agents/." >&2
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
link_path ".agents/sync-context.sh" "$PROJECT_DIR/sync-context.sh"

# Cópia, não symlink: os valores são do projeto. O project-config.md vai pro Git
# do projeto; o .env, não (tem segredo). Arquivo já existente nunca é sobrescrito.
seed_file() {
  local src="$1" dest="$2" label="$3"

  if [[ -f "$dest" ]]; then
    echo "$label já existe — não sobrescrito. Campos novos do template entram na mão."
  else
    cp "$src" "$dest"
    echo "$label criado a partir do template — PREENCHA antes de usar as skills."
  fi
}

seed_file "$HARNESS_DIR/project-config.template.md" "$PROJECT_DIR/project-config.md" "project-config.md"
seed_file "$HARNESS_DIR/.env.example" "$PROJECT_DIR/.env" ".env"

echo "Regras invariantes do harness vivem em .agents/ENGAGEMENT.md (versionadas, carregadas pelas skills/personas)."
echo "AGENTS.md/CLAUDE.md na raiz são override LOCAL opcional do projeto — crie se precisar; não substituem o ENGAGEMENT.md."
echo "Harness instalado em $PROJECT_DIR"
