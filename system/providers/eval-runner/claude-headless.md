---
selecao: claude-headless
default: true
capacidades: [roteamento-skill, julgamento]
requisitos:
  binarios: [claude]
---

# Provider: eval-runner — implementação claude headless (default)

`claude -p` com saída estruturada. É o default porque é o único runtime, hoje, que expõe
**qual skill engajou** — o que torna o caso de roteamento observável sem o `plugin eval`.

**Ativa quando** `EVAL_RUNNER=claude-headless` (ou vazio).
**Capacidades:** `roteamento-skill` · `julgamento`. **Não suporta** `ablacao` nem `fixture` —
para isso, `claude-plugin-eval.md`.

## Roteamento

```bash
claude -p "<frase>" --output-format stream-json --verbose \
  --disallowedTools Write Edit Bash WebFetch WebSearch
```

A chamada da skill aparece como um evento com `"name":"Skill"` e o nome no input:

```
grep -o '"skill":"[^"]*"' <stream>
```

Presente o nome de quem `atende` → passou. Presente o nome de qualquer `confunde_com` →
falso positivo de gatilho, reprova.

- `--verbose` é **obrigatório** com `stream-json`; sem ele o stream sai sem os eventos de
  tool e nada é observável.
- As tools de escrita saem por `--disallowedTools`: roteamento se decide no primeiro turno.
- **Não sobrescreva `CLAUDE_CONFIG_DIR`.** A credencial mora lá; apontar para um diretório
  vazio devolve `Not logged in · Please run /login` e o caso reprova por motivo errado.
- Plugin global do usuário (marketplace, MCP) carrega junto e aparece no stream. Não
  atrapalha a leitura — filtre pelo nome da skill, não pela contagem de tools.

## Julgamento

Mesma chamada, lendo a última mensagem. O veredito sai de uma segunda chamada ao próprio
`claude -p`, com o critério do caso e resposta fechada (`APROVADO`/`REPROVADO`) — o juiz é
sempre o runtime da implementação ativa, nunca um fixo.

## Validar

```bash
claude --version                     # binário no PATH
cd <projeto descartável> && claude -p "oi" --output-format stream-json --verbose | head -1
```

A primeira linha traz `"type":"system","subtype":"init"` com `slash_commands` — se as skills
do harness não estiverem ali, o workspace foi montado errado (`INTERFACE.md`, contrato
transversal).
