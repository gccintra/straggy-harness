#!/usr/bin/env bash
# Roda a camada de COMPORTAMENTO dos evals (docs/ARCHITECTURE.md §9).
#
# A camada de contrato é do build.sh e não passa por aqui. Este script executa a interface
# system/providers/eval-runner/: lê as fontes neutras da visão resolvida e despacha para a
# implementação ativa. Capacidade que a implementação não tem vira caso NÃO-RODADO
# explícito — nunca verde.
#
#   --runner NOME   implementação (default: EVAL_RUNNER do .env, ou claude-headless)
#   --caso GLOB     filtra por id do caso
#   --tipo TIPO     roteamento | modo-degradado
#   --skill NOME    roda só os casos de um workflow (skill ou persona)
#   --skills DIR    visão resolvida (default: runtime/skills)
#   --saida DIR     onde gravar resultado.json + report.html
#   --sem-report    não gera o HTML
#   --keep          preserva o projeto descartável
#
# Saída: 0 tudo passou · 1 alguma falha · 2 uso incorreto · 3 nenhum runner utilizável.
set -uo pipefail

HARNESS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_DIR="$HARNESS_DIR/runtime/skills"
PROVIDERS="$HARNESS_DIR/system/providers/eval-runner"
FILTRO_CASO="*"; FILTRO_TIPO=""; FILTRO_SKILL="*"; RUNNER=""; KEEP=0; REPORT=1
SAIDA="$HARNESS_DIR/runtime/evals/$(date +%Y-%m-%d_%H%M%S)"

while [ $# -gt 0 ]; do
  case "$1" in
    --runner) RUNNER="${2:?--runner exige um nome}"; shift ;;
    --caso)   FILTRO_CASO="${2:?--caso exige um glob}"; shift ;;
    --tipo)   FILTRO_TIPO="${2:?--tipo exige um tipo}"; shift ;;
    --skill)  FILTRO_SKILL="${2:?--skill exige um nome}"; shift ;;
    --skills) SKILLS_DIR="${2:?--skills exige um caminho}"; shift ;;
    --saida)  SAIDA="${2:?--saida exige um caminho}"; shift ;;
    --sem-report) REPORT=0 ;;
    --keep)   KEEP=1 ;;
    -h|--help) sed -n '2,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "uso: eval.sh [--runner N] [--caso GLOB] [--tipo T] [--skill NOME] [--saida DIR] [--sem-report] [--keep]" >&2; exit 2 ;;
  esac
  shift
done

# Seleção: flag > .env do projeto > default da interface.
if [ -z "$RUNNER" ]; then
  ENV_FILE="${HARNESS_ENV_FILE:-$HARNESS_DIR/../.env}"
  [ -f "$ENV_FILE" ] && RUNNER="$(sed -n 's/^[[:space:]]*EVAL_RUNNER=//p' "$ENV_FILE" | tail -1 | tr -d '"'"'"' ')"
  RUNNER="${RUNNER:-claude-headless}"
fi

if [ "$RUNNER" = "none" ]; then
  echo "EVAL_RUNNER=none — camada de comportamento desligada. A de contrato continua em build.sh --strict." >&2
  exit 3
fi

IMPL="$PROVIDERS/$RUNNER.md"
[ -f "$IMPL" ] || IMPL="$HARNESS_DIR/org/providers/eval-runner/$RUNNER.md"
if [ ! -f "$IMPL" ]; then
  echo "ERRO: '$RUNNER' não é implementação de eval-runner. Veja $PROVIDERS/INTERFACE.md." >&2
  exit 3
fi

capacidades="$(sed -n 's/^capacidades:[[:space:]]*\[\(.*\)\]/\1/p' "$IMPL")"
tem() { [[ ",${capacidades// /}," == *",$1,"* ]]; }

binario="$(sed -n 's/^[[:space:]]*binarios:[[:space:]]*\[\(.*\)\]/\1/p' "$IMPL" | tr -d ' ' | cut -d, -f1)"
if ! command -v "$binario" >/dev/null 2>&1; then
  echo "ERRO: '$RUNNER' exige o binário '$binario' no PATH." >&2
  exit 3
fi

# ── Projeto descartável: o mesmo layout que o install.sh produz ───────────────
# Rodar na raiz do harness não testa nada — lá as skills não estão instaladas.
WS="$(mktemp -d)"
cleanup() { [ "$KEEP" = 1 ] && echo "workspace preservado: $WS" >&2 || rm -rf "$WS"; }
trap cleanup EXIT

git -C "$WS" init -q
ln -s "$HARNESS_DIR" "$WS/.agents"
ln -s ".agents/runtime/claude"   "$WS/.claude"
ln -s ".agents/runtime/codex"    "$WS/.codex"
ln -s ".agents/runtime/opencode" "$WS/.opencode"
ln -s ".agents/runtime/cursor"   "$WS/.cursor"
cp "$HARNESS_DIR/project-config.template.yaml" "$WS/project-config.yaml" 2>/dev/null || true
# O .env NÃO é copiado de propósito: ausência de configuração é o cenário dos casos
# modo-degradado, e herdar credencial os faria passar por engano.

campo() { sed -n "s/^$2:[[:space:]]*//p" "$1" | head -1; }
bloco() {  # escalar de bloco `>` — junta as linhas indentadas seguintes
  awk -v k="$2" '$0 ~ "^"k":[[:space:]]*>" {f=1; next} f && /^[[:space:]]+/ {gsub(/^[[:space:]]+/,""); printf "%s ", $0; next} f {exit} END {print ""}' "$1"
}
lista() { awk -v k="$2" '$0 ~ "^"k":" {f=1; next} f && /^[[:space:]]*-[[:space:]]/ {sub(/^[[:space:]]*-[[:space:]]*/,""); print; next} f && NF {exit}' "$1"; }

# ── Execução por runtime ─────────────────────────────────────────────────────
rodar() {  # $1 = frase → stdout: transcript bruto
  case "$RUNNER" in
    claude-headless)
      (cd "$WS" && claude -p "$1" --output-format stream-json --verbose \
         --disallowedTools Write Edit Bash WebFetch WebSearch 2>&1) ;;
    codex-exec)
      (cd "$WS" && codex exec --json --skip-git-repo-check "$1" < /dev/null 2>&1) ;;
    opencode-run)
      (cd "$WS" && opencode run --log-level ERROR "$1" 2>&1) ;;
    claude-plugin-eval)
      echo "IMPLEMENTACAO_DELEGADA" ;;
  esac
}

skills_engajadas() {  # transcript → nomes de skill, uma por linha
  grep -o '"skill":"[^"]*"' | sed 's/.*:"//;s/"//' | sort -u
}

ultima_mensagem() {
  case "$RUNNER" in
    claude-headless) python3 -c "
import json,sys
ultima=''
for l in sys.stdin:
    l=l.strip()
    if not l.startswith('{'): continue
    try: d=json.loads(l)
    except Exception: continue
    if d.get('type')=='result': ultima=d.get('result') or ultima
print(ultima)" ;;
    codex-exec) python3 -c "
import json,sys
ultima=''
for l in sys.stdin:
    l=l.strip()
    if not l.startswith('{'): continue
    try: d=json.loads(l)
    except Exception: continue
    it=d.get('item',{})
    if d.get('type')=='item.completed' and it.get('item_type')=='agent_message':
        ultima=it.get('text') or ultima
print(ultima)" ;;
    *) cat ;;
  esac
}

julgar() {  # $1 = resposta, $2 = critério → APROVADO|REPROVADO
  local p="Julgue a RESPOSTA contra o CRITÉRIO. Responda APENAS a palavra APROVADO ou REPROVADO.

CRITÉRIO:
$2

RESPOSTA:
$1"
  case "$RUNNER" in
    claude-headless|claude-plugin-eval) claude -p "$p" 2>/dev/null ;;
    codex-exec)  codex exec --skip-git-repo-check "$p" < /dev/null 2>/dev/null | tail -5 ;;
    opencode-run) opencode run --log-level ERROR "$p" 2>/dev/null | tail -5 ;;
  esac
}

# ── Registro ─────────────────────────────────────────────────────────────────
# Uma linha JSON por caso. O relatório é uma VISÃO deste arquivo, nunca uma segunda
# fonte — mesma regra do manifesto (docs/ARCHITECTURE.md §8).
mkdir -p "$SAIDA"
JSONL="$SAIDA/casos.jsonl"; : > "$JSONL"

registrar() {  # workflow caso tipo status motivo engajadas segundos
  python3 -c '
import json, sys
campos = ["workflow","caso","tipo","status","motivo","engajadas","segundos"]
d = dict(zip(campos, sys.argv[1:]))
d["engajadas"] = [x for x in d["engajadas"].split("\n") if x]
d["segundos"] = float(d["segundos"] or 0)
print(json.dumps(d, ensure_ascii=False))' "$@" >> "$JSONL"
}

agora() { python3 -c 'import time; print(time.time())'; }

# ── Laço ─────────────────────────────────────────────────────────────────────
passou=0; falhou=0; naorodou=0
printf '%s\n' "runner: $RUNNER · capacidades: ${capacidades:-—} · workspace: $WS"
echo

for fonte in "$SKILLS_DIR"/$FILTRO_SKILL/evals/$FILTRO_CASO/caso.yaml; do
  [ -f "$fonte" ] || continue
  caso="$(basename "$(dirname "$fonte")")"
  dono="$(basename "$(dirname "$(dirname "$(dirname "$fonte")")")")"
  tipo="$(campo "$fonte" tipo)"
  [ -n "$FILTRO_TIPO" ] && [ "$tipo" != "$FILTRO_TIPO" ] && continue

  frase="$(bloco "$fonte" frase)"
  rotulo="$dono/$caso"

  case "$tipo" in
    roteamento)
      if ! tem roteamento-skill; then
        printf '  NÃO-RODOU  %-46s %s não observa qual skill engajou\n' "$rotulo" "$RUNNER"
        registrar "$dono" "$caso" "$tipo" "nao-rodou" "capacidade ausente: roteamento-skill" "" 0
        naorodou=$((naorodou+1)); continue
      fi
      atende="$(campo "$fonte" atende)"
      rivais="$(lista "$fonte" confunde_com)"
      t0="$(agora)"
      engajadas="$(rodar "$frase" | skills_engajadas)"
      dt="$(python3 -c "print(f'{__import__('time').time() - $t0:.1f}')")"

      erros=""
      if [ "$atende" != "nenhuma" ] && [ -n "$atende" ]; then
        # a fonte mora no workflow que atende — é ele que precisa aparecer
        grep -qx "$dono" <<<"$engajadas" || erros="não disparou '$dono'"
      fi
      while IFS= read -r rival; do
        [ -z "$rival" ] && continue
        alvo="$(grep -l "^  id: $rival$" "$SKILLS_DIR"/*/SKILL.md 2>/dev/null | head -1)"
        alvo="${alvo:+$(basename "$(dirname "$alvo")")}"
        [ -z "$alvo" ] && continue
        grep -qx "$alvo" <<<"$engajadas" && erros="${erros:+$erros; }'$alvo' sequestrou a frase"
      done <<<"$rivais"

      if [ -z "$erros" ]; then
        printf '  PASSOU     %-46s %s\n' "$rotulo" "${engajadas:-—}"
        registrar "$dono" "$caso" "$tipo" "passou" "" "$engajadas" "$dt"
        passou=$((passou+1))
      else
        printf '  FALHOU     %-46s %s\n' "$rotulo" "$erros"
        registrar "$dono" "$caso" "$tipo" "falhou" "$erros" "$engajadas" "$dt"
        falhou=$((falhou+1))
      fi
      ;;

    modo-degradado)
      if ! tem julgamento; then
        printf '  NÃO-RODOU  %-46s %s não julga resposta\n' "$rotulo" "$RUNNER"
        registrar "$dono" "$caso" "$tipo" "nao-rodou" "capacidade ausente: julgamento" "" 0
        naorodou=$((naorodou+1)); continue
      fi
      dominio="$(campo "$fonte" provider)"
      t0="$(agora)"
      resposta="$(rodar "$frase" | ultima_mensagem)"
      dt="$(python3 -c "print(f'{__import__('time').time() - $t0:.1f}')")"
      criterio="$(sed -n '/^---$/,$p' "$PROVIDERS/criterios/modo-degradado.md" | tail -n +2 | sed "s/{dominio}/$dominio/g")"
      if grep -qi 'APROVADO' <<<"$(julgar "$resposta" "$criterio")"; then
        printf '  PASSOU     %-46s parou e avisou\n' "$rotulo"
        registrar "$dono" "$caso" "$tipo" "passou" "parou e avisou" "" "$dt"
        passou=$((passou+1))
      else
        printf '  FALHOU     %-46s %s\n' "$rotulo" "$(head -c 90 <<<"$resposta")"
        registrar "$dono" "$caso" "$tipo" "falhou" "$(head -c 240 <<<"$resposta")" "" "$dt"
        falhou=$((falhou+1))
      fi
      ;;
    *)
      printf '  NÃO-RODOU  %-46s tipo desconhecido: %s\n' "$rotulo" "$tipo"
      registrar "$dono" "$caso" "$tipo" "nao-rodou" "tipo desconhecido: $tipo" "" 0
      naorodou=$((naorodou+1)) ;;
  esac
done

echo
echo "passou: $passou · falhou: $falhou · não-rodou: $naorodou"

if [ "$REPORT" = 1 ]; then
  RUNNER="$RUNNER" CAPACIDADES="$capacidades" SKILLS_DIR="$SKILLS_DIR" \
  FILTRO_SKILL="$FILTRO_SKILL" FILTRO_TIPO="$FILTRO_TIPO" \
    python3 "$HARNESS_DIR/runtime/adapters/report.py" "$JSONL" "$SAIDA" \
    && echo "relatório: $SAIDA/report.html"
fi

[ "$falhou" -gt 0 ] && exit 1
exit 0
