#!/usr/bin/env bash
# CA da HRN-009: poda de contexto. Prova o que o disco consegue ver —
# portão, fontes, teto de palavras, cópia removida. Não substitui o build --strict.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONST="$ROOT/system/CONSTITUTION.md"
PS_PROF="$ROOT/system/professions/product-specialist/PROFESSION.md"
PS_REAS="$ROOT/system/professions/product-specialist/reasoning.md"
PD_PROF="$ROOT/system/professions/product-designer/PROFESSION.md"
PD_REAS="$ROOT/system/professions/product-designer/reasoning.md"
TL_PROF="$ROOT/system/professions/tech-lead/PROFESSION.md"
TL_REAS="$ROOT/system/professions/tech-lead/reasoning.md"
PACK="$ROOT/system/pack/workflows"

falta() { echo "poda-de-contexto: $1" >&2; exit 1; }

palavras() { wc -w < "$1" | tr -d ' '; }

teto() {
  local arquivo="$1" limite="$2" n
  n="$(palavras "$arquivo")"
  [ "$n" -le "$limite" ] || falta "$(basename "$arquivo") tem $n palavras (teto $limite)"
}

# CA-01 — seções §1–§7 estáveis; §8 saiu
for n in 1 2 3 4 5 6 7; do
  grep -qE "^## $n\\. " "$CONST" || falta "constituição sem §$n"
done
grep -qE "^## 8\\. " "$CONST" && falta "§8 ainda está na constituição"
grep -qF 'Aprovação de um passo não vale para o próximo.' "$CONST" || falta "write-gate perdeu a aprovação por passo"
grep -qF 'Um pedido = um passo.' "$CONST" || falta "portão perdeu um pedido = um passo"
grep -qF 'Nunca spawne persona ociosa.' "$CONST" || falta "delegação perdeu o autoguard de persona ociosa"
grep -qF 'Contrato e portão são invioláveis' "$CONST" || falta "§6 perdeu contrato e portão invioláveis"

# CA-02 — teto de palavras da spec
teto "$CONST" 750
teto "$PS_PROF" 450
teto "$PS_REAS" 450
teto "$PD_PROF" 400
teto "$PD_REAS" 450
teto "$TL_PROF" 323
teto "$TL_REAS" 291

# CA-03 — catálogo anotado saiu da profissão de produto; o ponteiro ficou
grep -qF 'methods/' "$PS_PROF" || falta "profissão de produto sem ponteiro para methods/"
grep -qF 'problem-framing' "$PS_PROF" && falta "catálogo de métodos ainda está na profissão de produto"
grep -qF 'org/professions/product-specialist/methods/' "$PS_PROF" || falta "perdeu o ponteiro de método da organização"

# CA-04 — carve-out do protótipo continua na profissão, não subiu para a L0
grep -qF 'rascunho local' "$PD_PROF" || falta "designer perdeu o carve-out do protótipo"
grep -qF 'não passa pelo' "$PD_PROF" || falta "carve-out não diz que o protótipo fica fora do write-gate"
grep -qF 'rascunho local' "$CONST" && falta "carve-out do protótipo vazou para a constituição"
grep -qF 'reference-authority.md' "$PD_PROF" || falta "tabela curta de métodos do designer sumiu"

# CA-05 — persona é ponteiro; a frase que o teste de fontes exige continua
for persona in product-specialist tech-lead product-designer; do
  arq="$PACK/$persona/PERSONA.md"
  grep -qF 'constituição §3' "$arq" || falta "$persona/PERSONA.md sem constituição §3"
  grep -qF 'Não duplique regra aqui.' "$arq" || falta "$persona/PERSONA.md voltou a carregar regra"
  grep -qF 'Autoguard' "$arq" && falta "$persona/PERSONA.md ainda repete o autoguard"
done
grep -qF 'rascunho local' "$PACK/product-designer/PERSONA.md" \
  && falta "carve-out voltou para a PERSONA do designer; mora na profissão"

# CA-06 — gatilho que era paráfrase do §3 saiu do reasoning
grep -qF 'devolver uma lista de perguntas' "$PS_REAS" \
  && falta "reasoning do PM ainda repete a autonomia do §3"
grep -qF 'Pedido que descreve só o resultado' "$PD_REAS" \
  && falta "reasoning do designer ainda repete o §3"
grep -qF 'reference-authority.md' "$PD_REAS" || falta "reasoning do designer perdeu a autoridade da referência"
grep -qF 'fatie pela jornada' "$PS_REAS" || falta "reasoning do PM perdeu o corte por jornada"

echo "poda-de-contexto: CA-01 a CA-06 ok ($(palavras "$CONST")+$(palavras "$PS_PROF")+$(palavras "$PS_REAS")+$(palavras "$PD_PROF")+$(palavras "$PD_REAS") palavras nas cinco peças podadas)"
