#!/usr/bin/env bash
# Semeia o ambiente local de código do produto. Não clona, não grava credencial
# e não altera ~/.gitconfig. README existente não é sobrescrito.
set -euo pipefail

HARNESS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${1:?uso: seed-codigo-fonte.sh <raiz-do-projeto>}"
TEMPLATE="$HARNESS_DIR/codigo-fonte.README.md"
DEST="$PROJECT_DIR/codigo-fonte"
README="$DEST/README.md"
GITIGNORE="$PROJECT_DIR/.gitignore"
MARKER='/codigo-fonte/*'

mkdir -p "$DEST/repos"

if [[ -f "$README" ]]; then
  echo "codigo-fonte/README.md já existe — não sobrescrito."
else
  cp "$TEMPLATE" "$README"
  echo "codigo-fonte/README.md criado a partir do template."
fi

if [[ -f "$GITIGNORE" ]] && grep -qF "$MARKER" "$GITIGNORE"; then
  echo "codigo-fonte: .gitignore já cobre a pasta."
else
  if [[ -f "$GITIGNORE" && -s "$GITIGNORE" ]]; then
    [[ -n "$(tail -c1 "$GITIGNORE")" ]] && printf '\n' >> "$GITIGNORE"
    printf '\n' >> "$GITIGNORE"
  fi
  cat >> "$GITIGNORE" << 'EOF'
# codigo-fonte: versionar só o README. repos/ é ambiente local.
/codigo-fonte/*
!/codigo-fonte/README.md
EOF
  echo "codigo-fonte: bloco acrescentado ao .gitignore."
fi
