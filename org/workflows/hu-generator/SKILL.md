---
name: hu-generator
description: >
  Passo FINAL da documentação: transcreve um `.md` consolidado JÁ REVISADO (gerado pela skill
  doc-consolidator) para um `.docx` de História de Usuário — 9 seções. Use SOMENTE quando o
  usuário pedir EXPLICITAMENTE o docx/HU formal — "gera o docx", "agora o docx", "transforma
  o md em docx", "cria a HU formal" — E o `.md` da issue já existir. NÃO use para pedido
  genérico ("documenta a #NNN"): isso gera o `.md` primeiro via doc-consolidator, com parada
  para revisão humana. Só transcreve o `.md`; não relê o discovery. Output é SEMPRE um `.docx`.
---

# hu-generator — workflow L2 (transcrição mecânica)

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` §5 (um pedido = um passo; nunca gerar o `.md` daqui) |
| Provider | `system/providers/docs-output/` — `pandoc-docx.md` tem o uso do `generate_doc.py`, logo, prints e validação |
| Formatos | `references/template.md` (seções) · `references/exemplos.md` (tom) |
| L3 | `project-config.yaml` (`identidade.token_arquivo`, `identidade.responsavel_padrao`; vazio → placeholder) |

## Fluxo

1. **Localizar o `.md`**: `ls outputs/${ID}_*/HU*${ID}*`. **Não existe → PARE** e aponte o
   `doc-consolidator`. Existe → ele é a **única fonte de conteúdo**; não releia discovery,
   não reescreva nada.
2. **Divisão em HUs**: se a demanda puder virar mais de uma, pergunte — nunca decida
   sozinho.
3. **Gerar**: `python3 generate_doc.py <md> outputs/{ID}_{NomeCurto}/HU{ID}_{TOKEN}_{NomeCurto}.docx`
   (detalhes e validação no provider). Rótulo do header inferido de `tipo: HU`.
4. Seção 8 com headings de prints → o script insere as imagens de `prototipo-prints/`
   (numeração contínua, partes `a/b/c`); divergência heading × arquivo interrompe.

**SEMPRE gere um `.docx`. Nunca apenas Markdown.**

Cada seção do `.md` vira a seção correspondente do `.docx`; apêndices são cortados.
Prints (Seção 8): procura primeiro `prototipo-prints/{IDENTIFICACAO}/` ao lado do `.md`
(fallback `prototipo-prints/` para pastas legadas) — detalhe completo em
`system/providers/docs-output/pandoc-docx.md`.
`.docx` errado → conserte o `.md` e regere; nunca edite o `.docx` nem o layout em prosa —
mudou o template, edita-se o `generate_doc.py`.

## Referências

* `references/template.md` — template de conteúdo das seções
* `references/exemplos.md` — exemplos de HUs (tom e nível de detalhe)
* `assets/header_logo.png` — logo do header (substitua pelo logo do projeto; 730×61 px). Ausente → header sem logo.
