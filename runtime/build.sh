#!/usr/bin/env bash
# Gera a visão resolvida do harness para os runtimes:
#   runtime/skills/    — workflows (system ∪ pack ∪ org), regra em docs/ARCHITECTURE.md §3
#   runtime/claude/    — agents + commands, a partir dos PERSONA.md resolvidos
#   runtime/codex/     — agents/*.toml, idem
#   runtime/opencode/  — opencode.json, idem
# Rode depois de criar, renomear, desabilitar ou sobrescrever qualquer workflow ou persona.
set -euo pipefail

HARNESS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SYS_DIR="$HARNESS_DIR/system/workflows"
PACK_DIR="$HARNESS_DIR/system/pack/workflows"
ORG_DIR="$HARNESS_DIR/org/workflows"
OUT_DIR="$HARNESS_DIR/runtime/skills"
ADAPTERS_DIR="$HARNESS_DIR/runtime/adapters"
LIST=0
[ "${1:-}" = "--list" ] && LIST=1

abs() { (cd "$(dirname "$1")" && printf '%s/%s\n' "$(pwd)" "$(basename "$1")"); }

# Só diretórios são workflow — arquivo solto na raiz (README.md, notas) é ignorado.
list_names() {
  for d in "$SYS_DIR" "$PACK_DIR" "$ORG_DIR"; do
    [ -d "$d" ] || continue
    find "$d" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null || true
  done | sort -u
}

# Copia a árvore de $1 para $OUT_DIR/$2 como symlinks por arquivo (override por caminho).
overlay() {
  local src="$1" name="$2" rel
  (cd "$src" && find . \( -type f -o -type l \) -print) | sed 's|^\./||' | while read -r rel; do
    mkdir -p "$OUT_DIR/$name/$(dirname "$rel")"
    ln -sfn "$(abs "$src/$rel")" "$OUT_DIR/$name/$rel"
  done
}

rm -rf "$OUT_DIR"
mkdir -p "$OUT_DIR"

warnings=0
[ "$LIST" = "1" ] && printf '%-26s %s\n' "WORKFLOW" "ORIGEM"

for name in $(list_names); do
  sys="$SYS_DIR/$name"; pack="$PACK_DIR/$name"; org="$ORG_DIR/$name"
  origin=""

  if [ -d "$sys" ]; then
    if [ -d "$org" ] || [ -d "$pack" ]; then
      echo "aviso: '$name' é workflow de sistema (não-forkável) — override ignorado." >&2
      warnings=$((warnings + 1))
    fi
    ln -sfn "$(abs "$sys")" "$OUT_DIR/$name"
    origin="sistema"
  elif [ -d "$org" ] && [ -f "$org/DISABLED" ]; then
    continue
  elif [ -d "$pack" ] && [ -d "$org" ]; then
    overlay "$pack" "$name"
    overlay "$org" "$name"
    origin="org+pack"
  elif [ -d "$pack" ]; then
    ln -sfn "$(abs "$pack")" "$OUT_DIR/$name"
    origin="pack"
  else
    ln -sfn "$(abs "$org")" "$OUT_DIR/$name"
    origin="org"
  fi

  if [ ! -f "$OUT_DIR/$name/SKILL.md" ]; then
    echo "aviso: '$name' não tem SKILL.md." >&2
    warnings=$((warnings + 1))
  fi
  [ "$LIST" = "1" ] && printf '%-26s %s\n' "$name" "$origin"
done

count=$(ls -1 "$OUT_DIR" | wc -l | tr -d ' ')

# Ponto de descoberta de skills do Codex: <projeto>/.agents/skills/<nome>/SKILL.md.
# É symlink versionado no repo; recriado aqui caso alguém apague.
ln -sfn runtime/skills "$HARNESS_DIR/skills"

# ── Adapters de runtime, gerados a partir dos PERSONA.md resolvidos ────────────
if ! command -v python3 >/dev/null 2>&1; then
  echo "ERRO: python3 é necessário para gerar os adapters de runtime." >&2
  exit 1
fi

personas=$(HARNESS_DIR="$HARNESS_DIR" ADAPTERS_DIR="$ADAPTERS_DIR" OUT_DIR="$OUT_DIR" \
  python3 "$ADAPTERS_DIR/render.py")

echo "runtime/skills: $count workflows resolvidos ($warnings aviso(s)). Origem de cada um: ./runtime/build.sh --list"
echo "adapters: $personas"
