#!/usr/bin/env bash
# CA-01 a CA-04 de docs/mudancas/HRN-007_ambiente-de-codigo-fonte.md
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SEED="$ROOT/seed-codigo-fonte.sh"
WS="$(mktemp -d)"
trap 'rm -rf "$WS"' EXIT

git -C "$WS" init -q
"$SEED" "$WS"

[[ -f "$WS/codigo-fonte/README.md" ]]
[[ -d "$WS/codigo-fonte/repos" ]]
grep -qF '/codigo-fonte/*' "$WS/.gitignore"
grep -qF '!/codigo-fonte/README.md' "$WS/.gitignore"

printf '\nMARCA\n' >> "$WS/codigo-fonte/README.md"
cp "$WS/.gitignore" "$WS/.gitignore.antes"
"$SEED" "$WS"
grep -qF 'MARCA' "$WS/codigo-fonte/README.md"
cmp "$WS/.gitignore.antes" "$WS/.gitignore"
[[ "$(grep -cF '/codigo-fonte/*' "$WS/.gitignore")" -eq 1 ]]

[[ ! -e "$WS/codigo-fonte/.git-credentials" ]]
[[ ! -e "$WS/codigo-fonte/repos/.git-credentials" ]]
[[ -z "$(find "$WS/codigo-fonte/repos" -mindepth 1 -print)" ]]

if grep -nE 'https?://' "$ROOT/codigo-fonte.README.md" "$SEED"; then
  echo "CA-04: template ou seed contém URL." >&2
  exit 1
fi
bloco="$(awk '/^codigo_fonte:/{f=1} f{print} f && /^[^ #]/{if(!/^codigo_fonte:/) exit}' "$ROOT/project-config.template.yaml")"
if printf '%s\n' "$bloco" | grep -nE 'https?://'; then
  echo "CA-04: bloco codigo_fonte contém URL." >&2
  exit 1
fi

echo "seed-codigo-fonte: CA-01 a CA-04 ok"
