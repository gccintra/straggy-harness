---
name: stop-slop
description: >
  Reescreve prosa para tirar cara de IA. Use sempre que o usuário disser "humaniza",
  "humaniza esse texto", "cheiro de IA", "cara de IA", "cara de ChatGPT", "parece GPT",
  "parece LLM", "padrões de LLM", "tira o GPT", "sem parecer máquina", "AI tells",
  "stop-slop", "stop slop", "slop", ou pedir para revisar um rascunho contra prosa
  formulaica. Não documenta demanda, não gera entregável, não reescreve código.
acao:
  id:        limpar-prosa
  rotulo:    Limpar prosa
  descricao: reescreve texto removendo padrões previsíveis de prosa de IA
objetivo: Tirar de um texto os padrões previsíveis de prosa de IA sem mudar o que ele afirma.
entrega:
  - o texto reescrito, com o mesmo conteúdo factual do original
  - score nas cinco dimensões (direteza, ritmo, confiança, autenticidade, densidade)
portoes:
  - reescrita entregue na conversa segue direto
  - gravar o resultado fora do rascunho (arquivo, demanda, wiki) é write-gate
encaixes:
  procedimento:
    caminho: references/procedimento.md
    rotulo:  Como fazer
    ajuda:   Como sua empresa revisa prosa gerada — o que corta, o que preserva, quando para.
    tipo:    texto-longo
---

# stop-slop — workflow L2 (pack padrão)

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` §1 — piso de **toda** prosa. Esta ação não o substitui. |
| Barra do passe | `references/phrases.md` · `references/structures.md` · `references/examples.md` |
| Formatos | encaixe `procedimento` |

Origem: [stop-slop](https://github.com/hardikpandya/stop-slop) (MIT, Hardik Pandya).

L0 §1 já vale em toda escrita, sem carregar esta skill. Esta ação é o **passe** sobre prosa
existente (rascunho colado, trecho a humanizar): barra completa, exemplos e score. Não
documenta demanda, não gera entregável, não reescreve código.

Portões: write-gate só se o resultado for gravado fora do rascunho (arquivo, issue, wiki).
Reescrita na conversa entrega direto.

**Procedimento (encaixe).** Existindo `references/procedimento.md`, ele é o passo a passo a
seguir. A moldura acima — ação, métodos, providers, portões e contrato de saída — vale
sempre e não é substituível.

## Contrato de saída

- Mesmo conteúdo factual do original. Sem argumento, dado ou ênfase que o texto não tinha.
- Sem os padrões de `phrases.md` e `structures.md` (PT e EN).
- Sujeito humano no ativo. Específico no lugar do vago. Ritmo variado. Sem travessão (em dash).
- Entrega o texto reescrito. Score abaixo de 35/50 → revisa antes de entregar.

| Dimensão | 1–10 pergunta |
|---|---|
| Direteza | Afirma ou anuncia? |
| Ritmo | Variado ou metrônomo? |
| Confiança | Respeita a inteligência de quem lê? |
| Autenticidade | Soa humano? |
| Densidade | Sobrou o que dá para cortar? |
