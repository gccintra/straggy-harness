---
selecao: codex-exec
capacidades: [julgamento]
requisitos:
  binarios: [codex]
---

# Provider: eval-runner — implementação codex exec

`codex exec --json` emite os eventos do turno como JSONL.

**Ativa quando** `EVAL_RUNNER=codex-exec`.
**Capacidades:** `julgamento`. **Não suporta** `roteamento-skill`.

## Por que não faz roteamento

O codex não tem conceito de skill. O adapter do harness ships persona
(`.codex/agents/*.toml`), invocada por escolha explícita — não existe roteamento por frase
para observar. Os eventos do turno são `agent_message` e `command_execution`; nenhum carrega
skill.

Caso `tipo: roteamento` sob esta implementação = indisponibilidade explícita, reportada por
caso. Nunca verde.

## Julgamento

```bash
codex exec --json --skip-git-repo-check "<frase>" < /dev/null
```

A última mensagem é o `text` do último evento `item.completed` com `item_type:
agent_message`. O veredito sai de uma segunda chamada ao próprio `codex exec`.

- `--skip-git-repo-check` é necessário quando o projeto descartável não é repo Git — sem
  ele o codex recusa com `Not inside a trusted directory`.
- `< /dev/null` evita o `Reading additional input from stdin...`, que trava a execução em
  script.
