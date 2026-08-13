#!/usr/bin/env bash
# Gera a visão resolvida do harness para os runtimes:
#   <runtime>/skills/        — workflows (system ∪ pack ∪ org), regra em docs/ARCHITECTURE.md §3 e §7
#   <runtime>/manifest.json  — o catálogo como dado (docs/ARCHITECTURE.md §8)
#   <runtime>/claude|codex|opencode/ — adapters, a partir dos PERSONA.md resolvidos
# Rode depois de criar, renomear, desabilitar ou sobrescrever qualquer workflow ou persona.
#
# Divisão de trabalho: este script resolve o sistema de arquivos; runtime/adapters/harness.py
# lê o contrato (frontmatter), valida e emite o manifesto. A tabela de resolução atravessa
# por stdin — a origem de cada workflow é decidida uma vez, aqui.
#
#   --list          imprime a origem resolvida e a ação de cada workflow
#   --strict        aviso vira reprovação (código 3) — modo para CI
#   --fix           regenera o bloco derivado de system/ACOES.md
#   --org  DIR      raiz da camada da organização   (env: HARNESS_ORG_DIR)
#   --out  DIR      raiz da saída gerada            (env: HARNESS_OUT_DIR)
#
# Códigos de saída: 0 ok · 2 uso incorreto · 3 contrato reprovado.
set -euo pipefail

HARNESS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SYS_DIR="$HARNESS_DIR/system/workflows"
PACK_DIR="$HARNESS_DIR/system/pack/workflows"
ADAPTERS_DIR="$HARNESS_DIR/runtime/adapters"
ACOES="$HARNESS_DIR/system/ACOES.md"
PROVIDERS_DIR="$HARNESS_DIR/system/providers"

ORG_ROOT="${HARNESS_ORG_DIR:-$HARNESS_DIR/org}"
RUNTIME_DIR="${HARNESS_OUT_DIR:-$HARNESS_DIR/runtime}"
LIST=0
HARNESS_STRICT="${HARNESS_STRICT:-0}"
HARNESS_FIX="${HARNESS_FIX:-0}"

while [ $# -gt 0 ]; do
  case "$1" in
    --list)   LIST=1 ;;
    --strict) HARNESS_STRICT=1 ;;
    --fix)    HARNESS_FIX=1 ;;
    --org)    ORG_ROOT="${2:?--org exige um caminho}"; shift ;;
    --out)    RUNTIME_DIR="${2:?--out exige um caminho}"; shift ;;
    -h|--help) sed -n '2,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "uso: build.sh [--list] [--strict] [--fix] [--org DIR] [--out DIR]" >&2; exit 2 ;;
  esac
  shift
done

ORG_DIR="$ORG_ROOT/workflows"
ORG_PROVIDERS_DIR="$ORG_ROOT/providers"
OUT_DIR="$RUNTIME_DIR/skills"
MANIFEST="$RUNTIME_DIR/manifest.json"

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

resolucao=""
avisos_resolucao=""

for name in $(list_names); do
  sys="$SYS_DIR/$name"; pack="$PACK_DIR/$name"; org="$ORG_DIR/$name"
  origin=""; org_ref=""; pack_ref=""

  if [ -d "$sys" ]; then
    if [ -d "$org" ] || [ -d "$pack" ]; then
      avisos_resolucao+="'$name' é workflow de sistema (não-forkável) — override ignorado."$'\n'
    fi
    ln -sfn "$(abs "$sys")" "$OUT_DIR/$name"
    origin="sistema"
  elif [ -d "$org" ] && [ -f "$org/DISABLED" ]; then
    continue
  elif [ -d "$pack" ] && [ -d "$org" ]; then
    # Moldura do pack + conteúdo da organização nos encaixes declarados (§7).
    overlay "$pack" "$name"
    overlay "$org" "$name"
    origin="pack+encaixes"; pack_ref="$(abs "$pack")"; org_ref="$(abs "$org")"
  elif [ -d "$pack" ]; then
    ln -sfn "$(abs "$pack")" "$OUT_DIR/$name"
    origin="pack"; pack_ref="$(abs "$pack")"
  else
    ln -sfn "$(abs "$org")" "$OUT_DIR/$name"
    origin="org"; org_ref="$(abs "$org")"
  fi

  resolucao+="$name	$origin	$pack_ref	$org_ref	$OUT_DIR/$name"$'\n'
done

count=$(ls -1 "$OUT_DIR" | wc -l | tr -d ' ')

# Ponto de descoberta de skills do Codex: <projeto>/.agents/skills/<nome>/SKILL.md.
# Só faz sentido quando a saída mora dentro do harness — no sandbox do produto, não.
if [ "$OUT_DIR" = "$HARNESS_DIR/runtime/skills" ] && [ -w "$HARNESS_DIR" ]; then
  ln -sfn runtime/skills "$HARNESS_DIR/skills"
fi

# ── Contrato e adapters, em Python ────────────────────────────────────────────
if ! command -v python3 >/dev/null 2>&1; then
  echo "ERRO: python3 é necessário para validar o contrato e gerar os adapters." >&2
  exit 1
fi

export HARNESS_DIR ADAPTERS_DIR OUT_DIR RUNTIME_DIR PACK_DIR MANIFEST ACOES
export PROVIDERS_DIR ORG_PROVIDERS_DIR
export HARNESS_STRICT HARNESS_FIX
export HARNESS_LIST="$LIST"
export RESOLUCAO_AVISOS="$avisos_resolucao"

# Contrato reprovado NÃO impede a geração: skills e adapters continuam sendo produzidos, e
# o código de saída reporta a reprovação no fim. Parar no meio deixaria os adapters velhos
# convivendo com skills novas — pior que o problema que a validação denuncia.
codigo=0
printf '%s' "$resolucao" | python3 "$ADAPTERS_DIR/harness.py" || codigo=$?
personas=$(python3 "$ADAPTERS_DIR/render.py")

echo "skills: $count workflow(s) resolvido(s) em $OUT_DIR"
echo "adapters: $personas"
exit "$codigo"
