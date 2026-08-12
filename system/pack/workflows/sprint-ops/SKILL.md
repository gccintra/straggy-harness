---
name: sprint-ops
description: >
  Gerencia sprints (milestones) no backlog do projeto — GitLab, Jira ou o que estiver
  configurado: criar nova sprint com datas e objetivo, fechar sprint atual e gerar sumário
  de conclusão, mover issues entre sprints em lote, listar issues de uma sprint com status
  resumido, e documentar a sprint preenchendo a descrição com Meta da Sprint, Prazos e
  Escopo. Use para qualquer operação de gestão de sprint — criar, fechar, mover issues, ver
  o que está numa sprint, ou "documentar a sprint", "preencher a milestone", "atualizar a
  descrição da sprint". IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes
  de qualquer operação no backlog.
---

# sprint-ops — workflow L2 (pack padrão)

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` (fechar sprint, mover lote, atualizar descrição = escrita → preview + aprovação, cada operação) |
| Provider | `system/providers/backlog/` — **sem fallback local**. Capacidade exigida: `sprints` |
| Métodos | `system/professions/product-specialist/methods/sprint-goal.md` (meta é outcome) |
| Formatos | `references/milestone-doc.md` — template da descrição de sprint (a organização sobrescreve este arquivo para impor o formato dela) |

Sprint = milestone; termos intercambiáveis.

## Operações e bindings

- **Listar**: sprints ativas/todas; issues de uma sprint apresentadas como tabela Markdown
  (nunca dump bruto).
- **Criar**: pergunte o que faltar — nome, datas, objetivo. **Padrão de nome**: verifique
  as sprints existentes e siga o mesmo (ex.: `Sprint YYYY.NN`); sem padrão → sugira e
  aguarde confirmação.
- **Fechar**: gere o sumário antes (fechadas/abertas, taxa de conclusão, lista das não
  entregues) → confirmar → fechar. Fechar sprint não fecha issues.
- **Mover em lote**: liste as issues (default: as abertas remanescentes do sumário) →
  confirmar → mover uma a uma → reportar progresso.
- **Documentar sprint**: buscar datas e descrição existentes → **Meta da Sprint**: se já
  existe na descrição, reutilize sem alterar; se não, **carregue `sprint-goal-generator`**
  — nunca escreva a meta por conta própria → montar a descrição pelo template do
  `references/` (todas as proibições do template valem) → preview → confirmar → atualizar
  a demanda pelo provider.

## Registro

Documentação de sprint gera `history/YYYY-MM-DD_sprint_doc_[SPRINT].md`: operação, URL,
concluídas/não concluídas, meta.
