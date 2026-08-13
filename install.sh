#!/usr/bin/env bash
set -euo pipefail

HARNESS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Onde mora a camada da organização. Default: dentro do harness. Repositório próprio
# montado noutro lugar (ou materializado pelo produto) → aponte HARNESS_ORG_DIR.
ORG_ROOT="${HARNESS_ORG_DIR:-$HARNESS_DIR/org}"

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

# Cópia, não symlink: os valores são do projeto. O project-config.yaml vai pro Git
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

seed_file "$HARNESS_DIR/project-config.template.yaml" "$PROJECT_DIR/project-config.yaml" "project-config.yaml"
seed_file "$HARNESS_DIR/.env.example" "$PROJECT_DIR/.env" ".env"

# Camada da organização: POSSE do cliente, fora do Git do harness (.gitignore). O harness
# ships só o scaffold; aqui ele é semeado arquivo a arquivo, nunca sobrescrevendo.
seed_org_layer() {
  local scaffold="$HARNESS_DIR/system/pack/org-scaffold"
  local created=0 rel

  while IFS= read -r rel; do
    local dest="$ORG_ROOT/$rel"
    [[ -f "$dest" ]] && continue
    mkdir -p "$(dirname "$dest")"
    cp "$scaffold/$rel" "$dest"
    created=$((created + 1))
  done < <(cd "$scaffold" && find . -type f | sed 's|^\./||')

  mkdir -p "$ORG_ROOT/workflows"

  if (( created > 0 )); then
    echo "$ORG_ROOT: $created arquivo(s) semeado(s) do scaffold — PREENCHA ORG.md (língua, nomenclatura, papéis, funil)."
  else
    echo "$ORG_ROOT: já existe, nada semeado — camada da organização preservada."
  fi
}

seed_org_layer

if [[ -f "$PROJECT_DIR/project-config.md" ]]; then
  echo "AVISO: project-config.md (formato antigo) ainda existe. A config agora é project-config.yaml — migre os valores e remova o .md."
fi

# Workflows resolvidos (system ∪ pack ∪ org) — pasta gerada, fora do Git.
"$HARNESS_DIR/runtime/build.sh" --org "$ORG_ROOT"

echo "Camadas: system/ (imutável: CONSTITUTION + professions + providers + pack padrão) e org/ (sua: ORG.md + workflows/professions/providers, fora do Git do harness). Ver .agents/README.md."
echo "Criou/renomeou/desabilitou workflow? Rode .agents/runtime/build.sh de novo."
echo "AGENTS.md/CLAUDE.md na raiz são override LOCAL opcional do projeto — complementam, não substituem a CONSTITUTION."
echo "Harness instalado em $PROJECT_DIR"
