#!/usr/bin/env bash
# Bootstrap público do harness. Não assume checkout local — clona em .agents/ e
# deixa o install.sh ligar os runtimes (Claude, Codex, OpenCode, Cursor CLI).
#
#   npx straggy-harness
#   npx github:gccintra/straggy-harness
#   curl -fsSL https://raw.githubusercontent.com/gccintra/straggy-harness/main/get.sh | bash
#
# HARNESS_REPO  URL do Git (default: este repositório)
# HARNESS_REF   branch ou tag (default: main)
#
# docs/ não entra no working tree: é material do repositório do harness
# (discovery, PRD, arquitetura de produto), não do projeto que instala.
# Quem for editar o harness: git -C .agents sparse-checkout add docs
set -euo pipefail

REPO="${HARNESS_REPO:-https://github.com/gccintra/straggy-harness.git}"
REF="${HARNESS_REF:-main}"

need() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Falta $1 — o bootstrap precisa dele no PATH." >&2
    exit 1
  }
}

need git
need bash

PROJECT_DIR="$(git rev-parse --show-toplevel 2>/dev/null)" || {
  echo "Rode na raiz de um repositório Git — o harness mora em <projeto>/.agents/." >&2
  exit 1
}

AGENTS="$PROJECT_DIR/.agents"

clone_harness() {
  echo "Clonando $REPO ($REF) → .agents/ (sem docs/)"
  git clone --filter=blob:none --sparse --branch "$REF" "$REPO" "$AGENTS"
  git -C "$AGENTS" sparse-checkout init --no-cone
  git -C "$AGENTS" sparse-checkout set '/*' '!/docs/'
}

if [[ -e "$AGENTS" ]]; then
  if [[ ! -d "$AGENTS/.git" ]]; then
    echo "$AGENTS já existe e não é um clone Git. Mova ou remova e execute de novo." >&2
    exit 1
  fi
  echo ".agents já está no lugar — configurando os runtimes."
else
  clone_harness
fi

exec "$AGENTS/install.sh"
