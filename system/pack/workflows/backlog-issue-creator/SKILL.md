---
name: backlog-issue-creator
description: >
  Cria e refina demandas do backlog com template estruturado, triagem MoSCoW e labels
  corretas. Acione quando o usuário mencionar criar issue, item de backlog, demanda,
  feature, bug, melhoria ou qualquer coisa que precise ser rastreada — em português ou
  inglês (criar issue, demanda, backlog, bug, melhoria, feature, nova funcionalidade, erro,
  tarefa). Acione também para refinar/enriquecer demanda existente com pouca informação
  ("refina a #NNN", "completa", "a issue só tem título"). IMPORTANTE: leia
  .agents/system/providers/backlog/INTERFACE.md antes de qualquer operação no backlog.
---

# backlog-issue-creator — workflow L2 (pack padrão)

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` (criar/atualizar demanda = escrita → preview completo + aprovação) |
| Métodos | `system/professions/product-specialist/methods/moscow.md` (criticidade na entrada) |
| Provider | `backlog/` — **sem fallback local**. Capacidade exigida: `core` |
| Formatos | `references/templates.md` — template da descrição (a organização sobrescreve) |

## Bindings padrão

- **Registra o problema, não a solução.** Solução que veio junto no pedido vira nota para
  o discovery. Mecanismo, formato e tecnologia não entram na demanda.
- **Triagem MoSCoW na entrada**; score e quadrante só depois de solução definida
  (`discovery`).
- **Labels**: consulte a taxonomia real pelo provider (operação **listar labels**) antes de
  sugerir — nunca invente label nova sem aprovação.
- **Duplicata**: antes de criar, busque demandas parecidas pelo provider e mostre o que
  achou; comparar problema, não título.
- **Refino**: apresente a descrição enriquecida completa → aprovação → **atualizar
  demanda** pelo provider. Nunca sobrescreva conteúdo existente sem mostrar o antes.
- Falta de informação que muda o registro → UMA pergunta focada antes de escrever.
