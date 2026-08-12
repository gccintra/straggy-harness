---
name: sprint-goal-generator
description: >
  Gera a Meta da Sprint (Sprint Goal) no padrao do Guia do Scrum 2020, com foco em OUTCOME
  (ganho de valor para o usuario/negocio) e nao em output (funcionalidades entregues). Use
  sempre que o usuario pedir para criar, escrever, montar ou sugerir uma Meta da Sprint,
  Sprint Goal, objetivo da sprint, ou enviar HUs/backlog pedindo para definir a meta.
  Tambem quando perguntar qual seria a meta mesmo sem usar o termo exato. Trigger
  agressivo: qualquer combinacao de meta + sprint + contexto de desenvolvimento de software.
---

# sprint-goal-generator — workflow L2 (pack padrão)

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` |
| Método | `system/professions/product-specialist/methods/sprint-goal.md` — **é ele que define o que é meta boa, os anti-padrões e o contrato de saída.** Leia antes de gerar. |
| Provider | `system/providers/backlog/` — **com fallback local** (regime "modo local" da INTERFACE) |

## Bindings

- **Contexto**: use o conteúdo recebido (HUs/backlog). Recebeu só o número/nome da
  sprint → liste as demandas da sprint pelo provider + docs relevantes do projeto.
  Sem backlog configurado → peça HUs/backlog direto ou busque `history/*sprint*`/`outputs/`.
- **Input vago demais** ("metas pra sprint de login") → UMA pergunta antes de gerar:
  "qual é o principal ganho que o usuário ou negócio terá ao final desta Sprint?"
- **Saída**: o contrato do método (2-3 opções com por-que-é-outcome + como verificar +
  recomendação + alertas), apresentado com o contexto identificado e o tema central de
  valor.
- Quem grava a meta na sprint é o `sprint-ops` (com aprovação) — esta skill só propõe.
