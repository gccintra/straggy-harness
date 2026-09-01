---
selecao: opencode-run
capacidades: [julgamento]
requisitos:
  binarios: [opencode]
---

# Provider: eval-runner — implementação opencode run

`opencode run` executa uma mensagem e imprime a resposta.

**Ativa quando** `EVAL_RUNNER=opencode-run`.
**Capacidades:** `julgamento`. **Não suporta** `roteamento-skill`.

## Por que não faz roteamento de skill

O opencode roteia por **persona** e imprime qual escolheu na primeira linha
(`> product-specialist · <modelo>`) — é roteamento, mas do objeto errado para estes casos:
a fonte declara ação/skill, não persona. Enquanto não existir caso `tipo: persona`, a
capacidade não se declara.

## Julgamento

```bash
opencode run --log-level ERROR "<frase>"
```

- O `opencode.json` gerado referencia as skills por `{file:../.agents/runtime/skills/...}`.
  O projeto descartável **precisa** do symlink `.agents/`, senão a config é recusada antes
  de rodar (`bad file reference`).
- O modelo vem do `opencode.json`; conta sem acesso ao modelo configurado falha com erro de
  provedor, não de eval. Confira com `opencode run "oi"` antes de culpar o caso.
