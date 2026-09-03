---
name: sprint-ops
description: >
  Gerencia sprints (milestones/ciclos) no backlog do projeto — GitLab, Linear, Jira ou o que estiver
  configurado: criar nova sprint com datas e objetivo, fechar sprint atual e gerar sumário
  de conclusão, mover issues entre sprints em lote, listar issues de uma sprint com status
  resumido, e documentar a sprint preenchendo a descrição com Meta da Sprint, Prazos e
  Escopo. Use para qualquer operação de gestão de sprint — criar, fechar, mover issues, ver
  o que está numa sprint, ou "documentar a sprint", "preencher a milestone", "atualizar a
  descrição da sprint". IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes
  de qualquer operação no backlog.
acao:
  id: gerenciar-sprint
  rotulo: Gerenciar sprint
  descricao: cria, fecha, move e documenta sprints
objetivo: Operar a sprint no backlog — criar, listar, mover em lote, fechar e documentar.
entrega:
  - sprint criada, fechada ou com issues movidas, conforme a operação
  - descrição da sprint no template do encaixe `template-sprint`
  - registro em `{caminhos.historico}YYYY-MM-DD_sprint_doc_[SPRINT].md`
portoes:
  - cada operação de escrita tem preview e aprovação própria
  - fechar sprint gera o sumário antes e espera confirmação
  - capacidade `sprints-write` ausente → informa a indisponibilidade e nunca tenta o comando mesmo assim
  - a meta da sprint nunca é escrita aqui — vem da ação `definir-meta-de-sprint`
provider:
  dominio: backlog
  selecao: BACKLOG_PROVIDER
  capacidade: sprints
encaixes:
  procedimento:
    caminho: references/procedimento.md
    rotulo: Como fazer
    ajuda: A cadência de sprint da sua empresa — duração, quando abre e fecha, e o que precisa acontecer no fechamento.
    tipo: texto-longo
  template-sprint:
    caminho: references/milestone-doc.md
    rotulo: Modelo de sprint
    ajuda: O que a descrição de uma sprint da sua empresa carrega — meta, prazos e escopo.
    tipo: texto-longo
---

# sprint-ops — workflow L2 (pack padrão)

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` (fechar sprint, mover lote, atualizar descrição = escrita → preview + aprovação, cada operação) |
| Provider | `system/providers/backlog/` — **sem fallback local**. Capacidade exigida: `sprints` |
| Métodos | `system/professions/product-specialist/methods/sprint-goal.md` (meta é outcome) |
| Formatos | `references/milestone-doc.md` — template da descrição de sprint (a organização sobrescreve este arquivo para impor o formato dela) |

Sprint = milestone (GitLab/GitHub) = ciclo (Linear); termos intercambiáveis.

**Criar, editar e fechar sprint exigem `sprints-write`** — nem toda implementação tem
(`INTERFACE.md`). Faltando, informe a indisponibilidade nessas operações e siga com as
outras (listar, mover em lote, documentar); nunca tente o comando mesmo assim.


**Procedimento (encaixe).** Existindo `references/procedimento.md`, ele é o passo a passo a
seguir. A moldura acima — ação, métodos, providers, portões e contrato de saída — vale
sempre e não é substituível.

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

Documentação de sprint gera `{caminhos.historico}YYYY-MM-DD_sprint_doc_[SPRINT].md`: operação, URL,
concluídas/não concluídas, meta.
