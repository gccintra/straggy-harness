---
name: backlog-issue-creator
description: >
  Create and refine backlog issues with structured templates, MoSCoW prioritization, and proper labels.
  Trigger when the user mentions creating an issue, backlog item, demand, feature, bug, improvement,
  or anything that should be tracked — in English or Portuguese (criar issue, demanda, backlog, bug,
  melhoria, feature, nova funcionalidade, erro, tarefa). Also trigger when the user wants to refine
  or enrich an existing issue that has minimal information (refinar issue #NNN, completar, enriquecer,
  a issue só tem título). IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md
  antes de qualquer operação no backlog.
---

# backlog-issue-creator — workflow L2

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` (write-gate: criar/atualizar issue só com aprovação) |
| Métodos | `system/professions/product-specialist/methods/moscow.md` · `user-story.md` · gatilho "pedido chega como solução" em `system/professions/product-specialist/reasoning.md` |
| Provider | `system/providers/backlog/` — **sem fallback local** (regime "pare" da INTERFACE) |
| Formatos | `references/templates.md` (Template A — Feature · Template B — Bug) |

Dois fluxos: **Create** (issue nova) e **Refine** (enriquecer issue rasa — "refinar #NNN").
Ambos documentam **só o problema** — solução é do `discovery`. Ambíguo → pergunte qual.

## Bindings desta organização

- **Módulo no título**: `[TITLE] - [MODULO]` — módulo não é label. Infira de docs/issues
  existentes ou pergunte.
- **Labels**: consulte a taxonomia real pelo provider (operação **listar labels**) antes de sugerir — tipo
  (`TIPO::…`), prioridade (`PRIORIDADE::…`) e a label de workflow de entrada (ex.:
  `PARA DESCOBERTA`, aplicada após criar). Labels inferidas sempre confirmadas com o
  usuário.
- **Priorização na criação = só MoSCoW** (com justificativa). ICE nunca — Facilidade é
  incalculável antes de solução escolhida (ver `moscow.md`/`ice.md`).
- **Bug crítico bypassa MoSCoW**: qualquer SIM em — sistema indisponível para um perfil ·
  risco de perda/vazamento de dado · bloqueia fluxo core · afeta >30% dos usuários · sem
  workaround → Template B, PRIORIZACAO vira `MoSCoW: MUST / Classificação: CRITICAL — vai
  direto para a sprint atual.`, label critical do projeto.
- **Contexto antes de assumir**: docs do repo (ONEPAGE, `docs/`) + busca de issues
  similares (vocabulário do projeto). Entreviste só o que falta (o quê/quem/impacto/
  evidências/prazo) — 2 perguntas por vez, pare quando der para documentar.

## Portões

1. Apresentar a issue documentada (descrição + MoSCoW + módulo + labels) → perguntar se
   está correta → iterar.
2. "Crio a issue no GitLab?" → só criar após aprovação explícita.
3. Após criar: aplicar a label de workflow de entrada e devolver URL/ID.
4. Refine: apresentar a descrição enriquecida → aprovar → **atualizar demanda** pelo provider.

Falha do provider → reporte o erro verbatim, aponte o passo de autenticação da
implementação ativa, ofereça retry.
Nunca contorne autenticação.

## Regras

- Flow Refine enriquece o **problema** apenas — nunca solução, CA ou detalhe técnico.
- Issue que chega escrita como solução → descole o problema antes de preencher (o "Quero"
  é o QUÊ, nunca o COMO; a solução proposta vira nota para o discovery).
