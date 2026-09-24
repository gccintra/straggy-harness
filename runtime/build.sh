#!/usr/bin/env bash
# Gera a visão resolvida do harness para os runtimes:
#   <runtime>/skills/        — workflows (system ∪ pack ∪ org), regra em docs/ARCHITECTURE.md §3 e §7
#   <runtime>/manifest.json  — o catálogo como dado (docs/ARCHITECTURE.md §8)
#   <runtime>/claude|codex|opencode|cursor/ — adapters, a partir dos PERSONA.md resolvidos
# Rode depois de criar, renomear, desabilitar ou sobrescrever qualquer workflow ou persona.
#
# Divisão de trabalho: este script resolve o sistema de arquivos; runtime/adapters/harness.py
# lê o contrato (frontmatter), valida e emite o manifesto. A tabela de resolução atravessa
# por stdin — a origem de cada workflow é decidida uma vez, aqui.
#
#   --list          imprime a origem resolvida e a ação de cada workflow
#   --strict        aviso vira reprovação (código 3) — modo para CI
#   --fix           regenera os blocos derivados de system/ACOES.md e docs/WORKFLOWS.md
#   --check         só confere se a saída está em dia com as fontes (impressão digital);
#                   não gera nada. Usado pelos hooks do Git (.githooks/)
#   --org  DIR      raiz da camada da organização   (env: HARNESS_ORG_DIR)
#   --out  DIR      raiz da saída gerada            (env: HARNESS_OUT_DIR)
#   --env  FILE     .env do projeto, lido só para conferir se o provider selecionado
#                   suporta o que a organização preencheu   (env: HARNESS_ENV_FILE)
#
# Códigos de saída: 0 ok · 2 uso incorreto · 3 contrato reprovado · 4 saída desatualizada (--check).
set -euo pipefail

HARNESS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SYS_DIR="$HARNESS_DIR/system/workflows"
PACK_DIR="$HARNESS_DIR/system/pack/workflows"
ADAPTERS_DIR="$HARNESS_DIR/runtime/adapters"
ACOES="$HARNESS_DIR/system/ACOES.md"
DOC_WORKFLOWS="$HARNESS_DIR/docs/WORKFLOWS.md"
PROVIDERS_DIR="$HARNESS_DIR/system/providers"
SCHEMAS_DIR="$HARNESS_DIR/system/schemas"

ORG_ROOT="${HARNESS_ORG_DIR:-$HARNESS_DIR/org}"
RUNTIME_DIR="${HARNESS_OUT_DIR:-$HARNESS_DIR/runtime}"
# O harness mora em <projeto>/.agents/; ausente (produto, CI), a checagem de provider
# simplesmente não roda — não há instância para julgar.
ENV_FILE="${HARNESS_ENV_FILE:-$HARNESS_DIR/../.env}"
LIST=0
CHECK=0
HARNESS_STRICT="${HARNESS_STRICT:-0}"
HARNESS_FIX="${HARNESS_FIX:-0}"

while [ $# -gt 0 ]; do
  case "$1" in
    --list)   LIST=1 ;;
    --strict) HARNESS_STRICT=1 ;;
    --fix)    HARNESS_FIX=1 ;;
    --check)  CHECK=1 ;;
    --org)    ORG_ROOT="${2:?--org exige um caminho}"; shift ;;
    --out)    RUNTIME_DIR="${2:?--out exige um caminho}"; shift ;;
    --env)    ENV_FILE="${2:?--env exige um caminho}"; shift ;;
    -h|--help) sed -n '2,24p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "uso: build.sh [--list] [--strict] [--fix] [--check] [--org DIR] [--out DIR] [--env FILE]" >&2; exit 2 ;;
  esac
  shift
done

ORG_DIR="$ORG_ROOT/workflows"
ORG_PROVIDERS_DIR="$ORG_ROOT/providers"
OUT_DIR="$RUNTIME_DIR/skills"
MANIFEST="$RUNTIME_DIR/manifest.json"

# Impressão digital das fontes que o build lê (HRN-015). A saída é cópia desde a HRN-005:
# fonte editada sem build deixa todo runtime lendo instrução velha, sem erro nenhum.
IMPRESSAO="$RUNTIME_DIR/.impressao"
impressao() {
  local d fontes=()
  for d in "$HARNESS_DIR/system" "$ORG_ROOT" "$ADAPTERS_DIR"; do
    [ -d "$d" ] && fontes+=("$d")
  done
  {
    find "${fontes[@]}" -type f ! -path '*/__pycache__/*' ! -name '*.pyc' ! -name '.DS_Store'
    printf '%s\n' "$HARNESS_DIR/runtime/build.sh"
  } | LC_ALL=C sort | while read -r f; do
    printf '%s\n' "${f#"$HARNESS_DIR"/}"
    cat "$f"
  done | shasum -a 256 | cut -d' ' -f1
}

if [ "$CHECK" = 1 ]; then
  atual="$(impressao)"
  if [ -f "$IMPRESSAO" ] && [ "$(cat "$IMPRESSAO")" = "$atual" ]; then
    echo "runtime em dia com as fontes"
    exit 0
  fi
  echo "runtime desatualizado: fonte mudou desde o último build"
  exit 4
fi

abs() { (cd "$(dirname "$1")" && printf '%s/%s\n' "$(pwd)" "$(basename "$1")"); }

# Só diretórios são workflow — arquivo solto na raiz (README.md, notas) é ignorado.
list_names() {
  for d in "$SYS_DIR" "$PACK_DIR" "$ORG_DIR"; do
    [ -d "$d" ] || continue
    find "$d" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; 2>/dev/null || true
  done | sort -u
}

# Copia a árvore de $1 para $OUT_DIR/$2 arquivo a arquivo (override por caminho).
# Cópia, não symlink: o Codex descarta SKILL.md que é link de arquivo (segue só pasta).
# Pasta inteira também não: o eval grava prompt/graders em runtime/skills/ e um
# link de diretório faria essa escrita atravessar de volta para system/ ou org/.
overlay() {
  local src="$1" name="$2" rel
  (cd "$src" && find . \( -type f -o -type l \) -print) | sed 's|^\./||' | while read -r rel; do
    mkdir -p "$OUT_DIR/$name/$(dirname "$rel")"
    rm -f "$OUT_DIR/$name/$rel"
    cp "$src/$rel" "$OUT_DIR/$name/$rel"
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
    overlay "$sys" "$name"
    origin="sistema"
  elif [ -d "$org" ] && [ -f "$org/DISABLED" ]; then
    continue
  elif [ -d "$pack" ] && [ -d "$org" ]; then
    # Moldura do pack + conteúdo da organização nos encaixes declarados (§7).
    overlay "$pack" "$name"
    overlay "$org" "$name"
    origin="pack+encaixes"; pack_ref="$(abs "$pack")"; org_ref="$(abs "$org")"
  elif [ -d "$pack" ]; then
    overlay "$pack" "$name"
    origin="pack"; pack_ref="$(abs "$pack")"
  else
    overlay "$org" "$name"
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
export DOC_WORKFLOWS ORG_DIR
export PROVIDERS_DIR ORG_PROVIDERS_DIR SCHEMAS_DIR ENV_FILE
export HARNESS_STRICT HARNESS_FIX
export HARNESS_LIST="$LIST"
export RESOLUCAO_AVISOS="$avisos_resolucao"

# Contrato reprovado NÃO impede a geração: skills e adapters continuam sendo produzidos, e
# o código de saída reporta a reprovação no fim. Parar no meio deixaria os adapters velhos
# convivendo com skills novas — pior que o problema que a validação denuncia.
codigo=0
printf '%s' "$resolucao" | python3 "$ADAPTERS_DIR/harness.py" || codigo=$?

# A tabela de resolução atravessa por arquivo para o render (o stdin dele é o do build) —
# render_evals_* precisa dos mesmos workflows que a validação viu.
RESOLUCAO="$(mktemp)"; export RESOLUCAO
trap 'rm -f "$RESOLUCAO"' EXIT
printf '%s' "$resolucao" > "$RESOLUCAO"
personas=$(python3 "$ADAPTERS_DIR/render.py")

# Cursor: pasta inteira como os outros runtimes, se `.cursor` ainda não existe.
# Se o IDE já criou a pasta, planta só os `.mdc` — nunca substitui MCP/settings.
plant_cursor_rules() {
  local dest_dir="$1" target_prefix="$2" src="$RUNTIME_DIR/cursor/rules"
  local f base dest
  mkdir -p "$dest_dir"
  # Rule que o build plantou e deixou de gerar (persona virou só skill): link órfão sai.
  # Só link nosso e quebrado — arquivo do usuário nunca é tocado.
  for f in "$dest_dir"/*.mdc; do
    if [ -L "$f" ] && [ ! -e "$f" ]; then
      case "$(readlink "$f")" in "$target_prefix"/*) rm -f "$f" ;; esac
    fi
  done
  [ -d "$src" ] || return 0
  for f in "$src"/*.mdc; do
    [ -f "$f" ] || continue
    base="$(basename "$f")"
    dest="$dest_dir/$base"
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
      continue
    fi
    ln -sfn "$target_prefix/$base" "$dest"
  done
}

plant_cursor_discovery() {
  [ "$RUNTIME_DIR" = "$HARNESS_DIR/runtime" ] || return 0
  [ -w "$HARNESS_DIR" ] || return 0

  local dest target rules_prefix
  if [ "$(basename "$HARNESS_DIR")" = ".agents" ]; then
    local projeto
    projeto="$(cd "$HARNESS_DIR/.." && pwd)"
    [ -d "$projeto/.git" ] || return 0
    dest="$projeto/.cursor"
    target=".agents/runtime/cursor"
    rules_prefix=".agents/runtime/cursor/rules"
  else
    dest="$HARNESS_DIR/.cursor"
    target="runtime/cursor"
    rules_prefix="../../runtime/cursor/rules"
  fi

  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$target" ]; then
    return 0
  fi
  if [ ! -e "$dest" ]; then
    ln -s "$target" "$dest"
    return 0
  fi
  plant_cursor_rules "$dest/rules" "$rules_prefix"
}
plant_cursor_discovery

# Impressão só da saída padrão: build em --out temporário não diz nada do runtime real.
if [ "$RUNTIME_DIR" = "$HARNESS_DIR/runtime" ]; then
  impressao > "$IMPRESSAO"
fi

echo "skills: $count workflow(s) resolvido(s) em $OUT_DIR"
echo "adapters: $personas"
exit "$codigo"
