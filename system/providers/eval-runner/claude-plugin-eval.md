---
selecao: claude-plugin-eval
capacidades: [roteamento-skill, julgamento, ablacao, fixture]
requisitos:
  binarios: [claude]
---

# Provider: eval-runner — implementação claude plugin eval

O runner de eval nativo da Claude Code. É a única implementação com **ablação** (braço sem
o harness carregado, para medir o delta) e **fixture** (workspace montado por
`scaffold_script`), e a única que roda cada caso N vezes com juiz por votação.

**Ativa quando** `EVAL_RUNNER=claude-plugin-eval`.
**Capacidades:** `roteamento-skill` · `julgamento` · `ablacao` · `fixture`.

## Disponibilidade — leia antes de configurar

Early access, **habilitado por organização**. Não habilitado, os dois comandos imprimem
``​`plugin eval` is currently in early access`` e saem com 1. Autoteste:

```bash
cd $(mktemp -d) && claude plugin eval
# "early access"        → não habilitado
# "No eval cases found" → habilitado
```

Cliente first-party pega a habilitação sozinho depois de `claude update` e sessão nova.
Cliente que não busca flag de servidor (Bedrock/Vertex/Foundry, gateway com
`ANTHROPIC_BASE_URL`, ou `DISABLE_TELEMETRY`/`DO_NOT_TRACK`/`CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC`/`DISABLE_GROWTHBOOK`
setados) precisa da variável de habilitação dada no onboarding — **não invente o nome
dela**.

## Uso

Única implementação que consome **artefato em disco**: `render.py` traduz cada `caso.yaml`
para o formato dela (`evals/<caso>/prompt.md` + `graders/*.md`) dentro de
`runtime/skills/`. As implementações headless leem o `caso.yaml` direto.

```bash
claude plugin eval runtime/skills/<nome> --tag roteamento
claude plugin eval runtime/skills/<nome> --ablation with-without --runs 3
```

Alvo é sempre a visão resolvida. `--allow-tools` para tool com portão, `--scaffold` para
`case.yaml` com `scaffold_script`, `--threshold` para o corte de reprovação (default 1.0).
