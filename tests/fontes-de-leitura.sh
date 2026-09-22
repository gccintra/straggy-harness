#!/usr/bin/env bash
# CA-01 e CA-02 de docs/mudancas/HRN-008_fontes-de-leitura.md
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONST="$ROOT/system/CONSTITUTION.md"
PACK="$ROOT/system/pack/workflows"

falta() { echo "fontes-de-leitura: $1" >&2; exit 1; }

for trecho in \
  'codigo_fonte.caminho' \
  'caminhos.contexto' \
  'caminhos.entregaveis' \
  'caminhos.pasta_por_demanda' \
  'caminhos.historico' \
  'prototype/' \
  'solução vigente'
do
  grep -qF "$trecho" "$CONST" || falta "§3 sem $trecho"
done

for persona in product-specialist tech-lead product-designer; do
  for arq in SKILL.md PERSONA.md; do
    grep -qF 'constituição §3' "$PACK/$persona/$arq" \
      || falta "$persona/$arq não aponta a constituição §3"
  done
done

echo "fontes-de-leitura: CA-01 e CA-02 ok"
