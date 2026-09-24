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

# Cursor: igual aos outros quando `.cursor` ainda não existe (symlink da pasta
# inteira). Se o IDE já criou `.cursor/` (MCP, settings), planta só as rules —
# nunca substitui a pasta.
plant_cursor() {
  local dest="$PROJECT_DIR/.cursor"
  local target=".agents/runtime/cursor"
  local f base

  if [[ -L "$dest" && "$(readlink "$dest")" == "$target" ]]; then
    return 0
  fi
  if [[ ! -e "$dest" ]]; then
    ln -s "$target" "$dest"
    return 0
  fi

  mkdir -p "$dest/rules"
  for f in "$dest/rules"/*.mdc; do
    if [[ -L "$f" && ! -e "$f" && "$(readlink "$f")" == .agents/runtime/cursor/rules/* ]]; then
      rm -f "$f"
    fi
  done
  local src="$HARNESS_DIR/runtime/cursor/rules"
  [ -d "$src" ] || return 0
  for f in "$src"/*.mdc; do
    [ -f "$f" ] || continue
    base="$(basename "$f")"
    if [[ -e "$dest/rules/$base" && ! -L "$dest/rules/$base" ]]; then
      echo "Não alterado: $dest/rules/$base já existe." >&2
      continue
    fi
    ln -sfn ".agents/runtime/cursor/rules/$base" "$dest/rules/$base"
  done
}

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

# Chave que o template ganhou depois da instalação nunca chegava ao .env do projeto, e
# ausente ela cai no default da interface — que pode não ser o que a organização
# configurou. Anexa só o que falta, com o valor do template; valor já escolhido aqui
# jamais é tocado, e segredo nenhum é lido.
backfill_env() {
  local src="$1" dest="$2"
  [[ -f "$dest" ]] || return 0

  local novas=() chave
  while IFS= read -r chave; do
    grep -qE "^[[:space:]]*${chave}=" "$dest" || novas+=("$chave")
  done < <(grep -oE '^[A-Z][A-Z0-9_]*=' "$src" | sed 's/=$//')

  (( ${#novas[@]} )) || return 0

  {
    printf '\n# ── Adicionado por install.sh: chave(s) nova(s) do .env.example ──────\n'
    printf '# Valor default do template. Confira contra o que sua organização usa —\n'
    printf '# o significado de cada uma está no .env.example.\n'
    for chave in "${novas[@]}"; do
      grep -m1 -E "^${chave}=" "$src"
    done
  } >> "$dest"

  echo ".env: ${#novas[@]} chave(s) nova(s) anexada(s) com o default do template (${novas[*]}) — CONFIRA."
}

# Constituição sempre carregada: Claude (2.1.277+), Codex, OpenCode e Cursor leem
# AGENTS.md da raiz. Sem ele, no Claude e no Codex a L0 só entrava quando uma skill era
# acionada. O arquivo é do projeto: semeado só se não existir, nunca editado depois.
seed_agents_md() {
  local dest="$PROJECT_DIR/AGENTS.md" f
  if [[ ! -e "$dest" ]]; then
    cp "$HARNESS_DIR/AGENTS.template.md" "$dest"
    echo "AGENTS.md criado — aponta a constituição e o ORG.md para todos os runtimes."
  elif ! grep -q "system/CONSTITUTION.md" "$dest"; then
    echo "AVISO: AGENTS.md já existe e não aponta a constituição. Adicione a linha: @.agents/system/CONSTITUTION.md"
  fi
  for f in CLAUDE.md CLAUDE.local.md; do
    if [[ -f "$PROJECT_DIR/$f" ]] && ! grep -qE "@AGENTS\.md|system/CONSTITUTION\.md" "$PROJECT_DIR/$f"; then
      echo "AVISO: $f existe — o Claude Code lê ele no lugar do AGENTS.md. Adicione a linha @AGENTS.md em $f."
    fi
  done
}

# Clone antigo do get.sh excluía docs/ (sparse-checkout). As specs de mudança moram lá e
# precisam chegar no pull — desliga a exclusão, sem tocar em outro sparse que não o nosso.
if [[ -d "$HARNESS_DIR/.git" ]] \
  && git -C "$HARNESS_DIR" sparse-checkout list 2>/dev/null | grep -qx '!/docs/'; then
  git -C "$HARNESS_DIR" sparse-checkout disable
  echo ".agents: docs/ passa a vir no pull (sparse-checkout antigo desligado)."
fi

seed_file "$HARNESS_DIR/project-config.template.yaml" "$PROJECT_DIR/project-config.yaml" "project-config.yaml"
seed_file "$HARNESS_DIR/.env.example" "$PROJECT_DIR/.env" ".env"
backfill_env "$HARNESS_DIR/.env.example" "$PROJECT_DIR/.env"
seed_agents_md

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

# Ambiente local de código. Não clona e não grava credencial.
"$HARNESS_DIR/seed-codigo-fonte.sh" "$PROJECT_DIR"

# Hooks do Git do harness (HRN-017): pull, troca de branch, rebase e commit regeneram o
# runtime sozinhos — sem depender de abrir um agente.
if [[ -d "$HARNESS_DIR/.git" ]]; then
  git -C "$HARNESS_DIR" config core.hooksPath .githooks
fi

# Workflows resolvidos (system ∪ pack ∪ org) — pasta gerada, fora do Git.
"$HARNESS_DIR/build.sh" --org "$ORG_ROOT"

# Depois do build: harness.mdc só existe a partir daqui.
plant_cursor

echo "Camadas: system/ (imutável: CONSTITUTION + professions + providers + pack padrão) e org/ (sua: ORG.md + workflows/professions/providers, fora do Git do harness). Ver .agents/README.md."
echo "Criou/renomeou/desabilitou workflow? Rode .agents/build.sh de novo."
echo "Harness instalado em $PROJECT_DIR"
