---
name: backlog-prioritization
description: >
  Prioriza as demandas do backlog pelo funil MoSCoW → quadrante I×E → ICE score.
  Exporta os dados em lote, extrai ICE da descrição, ranqueia por MUST/
  SHOULD/COULD/WONT e por QUICK WIN/PLAN/LATER/DROP, detecta anomalias (label errada,
  ICE inconsistente, tipo errado na fila) e gera markdown em history/analyses/.
  Acione SEMPRE que o usuário mencionar: priorização, priorizar, ranking, lista ranqueada,
  ordem de prioridade, backlog priorizado, funil MoSCoW, ice score, quadrante I×E, quais
  issues entram primeiro, anomalia de prioridade, inconsistência de label, ou qualquer
  pedido que combine backlog + MoSCoW + ICE + ordenar + analisar.
  IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de qualquer
  operação no backlog.
---

# backlog-prioritization — workflow L2 (pack padrão)

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` (a skill **só identifica** — corrigir label/descrição é passo separado, aprovado pelo usuário) |
| Métodos | `system/professions/product-specialist/methods/moscow.md` · `ice.md` |
| Provider | `system/providers/backlog/` — **sem fallback local**. Capacidade exigida: `bulk-export` |
| Código | receita de export e parsing da implementação ativa (ex.: `system/providers/backlog/recipes/gitlab-glab-analysis.md`) |

## Bindings

- **O funil declarado manda.** Antes de qualquer análise, leia o documento em
  `caminhos.documento_priorizacao` (`project-config.yaml`); chave vazia → o funil está em
  `org/ORG.md`; nem lá → **pergunte e registre**, nunca decore. De lá saem: fórmula ICE,
  thresholds dos quadrantes, hierarquia MoSCoW, labels correspondentes, tipos com fila
  separada, critérios de anomalia. Aplique o que o documento descreve — nunca valores
  decorados.
- **Escopo default**: demandas abertas ainda **fora de sprint** — é a fila que a
  priorização ordena. O funil declarado pode restringir mais (labels de fila, tipos com
  fila separada); nesse caso ele manda. Pedido diferente ("só a sprint X") ajusta o filtro
  — ambíguo → pergunte. Nunca decore nome de label: confirme a taxonomia real pelo
  provider (operação **listar labels**).
- **Um export em lote** pela receita do provider → CSV em `data/issues_YYYY-MM-DD.csv`;
  toda a análise roda no arquivo local. Verifique o export (`wc -l` > 1) antes de seguir.
- **Detecção de anomalias é aberta**: as categorias da receita são ponto de partida;
  aplique todas as regras que o documento do projeto declarar como inconsistência.
- **Ordenação**: MoSCoW → quadrante → ICE decrescente.

## Contrato de saída

`history/analyses/YYYY-MM-DD_priorizacao_backlog.md`, com:

- Cabeçalho: data, nº de issues (com/sem ICE), funil, fonte CSV, referência ao doc do
  projeto.
- **Lista Priorizada** por seção `MoSCoW › Quadrante` (omitir seções vazias), tabela
  `# | IID | ICE | I | C | E | Tipo | Label | Título` — ICE em negrito (divergente →
  usar o calculado), anomalia inline com `⚠️` + nota sob a tabela, corrigida na sessão →
  `✅`.
- Seção **Anomalias** (uma subseção por categoria com ocorrência ≥1: IID, detalhe, ação).
- **Resumo de Ações Prioritárias** por severidade (alta 🔴 / média 🟠 / baixa 🟡 / info ℹ️).
- Referência canônica de formato/tom: a análise mais recente em `history/analyses/`.

CSV com data no nome — nunca sobrescrever o de dia anterior.
