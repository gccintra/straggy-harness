---
name: ht-generator
description: >
  Passo FINAL da documentação técnica: transcreve um `.md` consolidado JÁ REVISADO (gerado
  pela skill doc-consolidator) para um `.docx` de História Técnica — 6 seções (Por que
  precisamos disso, O que deve ser feito, Escopo, Critérios de Aceite, Dependências e
  restrições, O que será afetado). Demanda técnica sem persona de usuário final. Use SOMENTE
  quando o usuário pedir EXPLICITAMENTE o docx/HT formal — "gera o docx", "cria a HT formal"
  — E o `.md` da issue já existir. NÃO use para pedido genérico ("documenta a #NNN"): isso
  gera o `.md` primeiro via doc-consolidator, com parada para revisão. Nunca use para HU.
  Output é SEMPRE um `.docx`.
---

# ht-generator — workflow L2 (transcrição mecânica)

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` §5 (um pedido = um passo; nunca gerar o `.md` daqui) |
| Provider | `system/providers/docs-output/` — uso do `generate_doc.py`, logo e validação |
| Formatos | `references/template.md` · `references/exemplos.md` |
| L3 | `project-config.yaml` (`identidade.token_arquivo`, `identidade.responsavel_padrao`; vazio → placeholder) |

HT vs HU: sem usuário final impactado diretamente — benefício para sistema/plataforma/time
(migração, ambiente, performance, dependências, pipeline, logs). Tem tela/ação de usuário →
é HU. Ver `system/professions/tech-lead/reasoning.md`.

## Fluxo

1. **Localizar o `.md`**: `ls outputs/${ID}_*/HT*${ID}*`. **Não existe → PARE** e aponte o
   `doc-consolidator`. Existe → única fonte de conteúdo, transcrição mecânica.
2. **Divisão em HTs**: mais de uma possível → pergunte; nunca decida sozinho.
3. **Gerar**: `python3 generate_doc.py <md> outputs/{ID}_{NomeCurto}/HT{ID}_{TOKEN}_{NomeCurto}.docx`.
   Rótulo `HISTÓRIA TÉCNICA` inferido de `tipo: HT`. Validação no provider.

Tom do documento: português formal acessível, voz ativa, termo técnico explicado entre
parênteses. Nunca pedir detalhe técnico ao PO (tabela, endpoint) — infira ou deixe aberto
para o time. `.docx` errado → conserte o `.md` e regere.
