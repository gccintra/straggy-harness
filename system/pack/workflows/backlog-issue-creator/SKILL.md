---
name: backlog-issue-creator
description: >
  Cria e refina demandas do backlog com template estruturado, triagem de criticidade
  (MoSCoW ou o que o funil declarar) e labels
  corretas. Acione quando o usuário mencionar criar issue, item de backlog, demanda,
  feature, bug, melhoria ou qualquer coisa que precise ser rastreada — em português ou
  inglês (criar issue, demanda, backlog, bug, melhoria, feature, nova funcionalidade, erro,
  tarefa). Acione também para refinar/enriquecer demanda existente com pouca informação
  ("refina a #NNN", "completa", "a issue só tem título"). IMPORTANTE: leia
  .agents/system/providers/backlog/INTERFACE.md antes de qualquer operação no backlog.
acao:
  id: registrar-demanda
  rotulo: Registrar demanda
  descricao: registra e refina uma demanda no backlog
provider:
  dominio: backlog
  selecao: BACKLOG_PROVIDER
  capacidade: core
produz:
  id: demanda-registrada
  rotulo: Demanda registrada
encaixes:
  procedimento:
    caminho: references/procedimento.md
    rotulo: Como fazer
    ajuda: O passo a passo com que sua empresa registra e refina uma demanda — o que perguntar antes de abrir e como classificar.
    tipo: texto-longo
  template-demanda:
    caminho: references/templates.md
    rotulo: Modelo de demanda
    ajuda: O corpo que toda demanda registrada pela sua empresa deve ter — seções, campos obrigatórios e rótulos.
    tipo: texto-longo
---

# backlog-issue-creator — workflow L2 (pack padrão)

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` (criar/atualizar demanda = escrita → preview completo + aprovação) |
| Métodos | `system/professions/product-specialist/methods/moscow.md` (criticidade na entrada) · `user-story.md` · gatilho "pedido chega como solução" em `reasoning.md` |
| Provider | `backlog/` — **sem fallback local**. Capacidade exigida: `core` |
| Formatos | encaixe `template-demanda` — template da descrição |

Portões, nesta ordem: apresentar a demanda documentada e iterar → pedir aprovação explícita
para criar/atualizar no backlog → só então escrever. Nenhum é pulável pelo procedimento.


**Procedimento (encaixe).** Existindo `references/procedimento.md`, ele é o passo a passo a
seguir. A moldura acima — ação, métodos, providers, portões e contrato de saída — vale
sempre e não é substituível.

## Bindings padrão

- **Registra o problema, não a solução.** Solução que veio junto no pedido vira nota para
  o discovery. Mecanismo, formato e tecnologia não entram na demanda.
- **Só a etapa de triagem na entrada** — a primeira etapa do funil declarado (encaixe
  `funil` da ação `priorizar-backlog`), com justificativa. Dimensões e score só depois de
  solução definida (`discovery`): facilidade é incalculável antes de existir solução.
- **Labels**: consulte a taxonomia real pelo provider (operação **listar labels**) antes de
  sugerir — nunca invente label nova sem aprovação.
- **Duplicata**: antes de criar, busque demandas parecidas pelo provider e mostre o que
  achou; comparar problema, não título.
- **Refino**: apresente a descrição enriquecida completa → aprovação → **atualizar
  demanda** pelo provider. Nunca sobrescreva conteúdo existente sem mostrar o antes.
- Falta de informação que muda o registro → UMA pergunta focada antes de escrever.
