---
name: backlog-analysis
description: >
  Analisa o backlog do projeto a partir de um único export em lote do backlog,
  salvando o CSV bruto no repositório e gerando relatórios em Markdown com métricas,
  scores e gráficos texto. Use esta skill sempre que o usuário pedir análise de sprint,
  métricas do backlog, status de issues, velocidade do time, distribuição por tipo ou
  prioridade, burndown, ou qualquer visão quantitativa do backlog — com ou sem filtro
  de sprint. IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de
  qualquer operação no backlog.
---

# backlog-analysis — workflow L2 (pack padrão)

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` |
| Métodos | `system/professions/product-specialist/methods/ice.md` (funil e leitura de score) |
| Provider | `system/providers/backlog/` — **sem fallback local**. Capacidade exigida: `bulk-export` |
| Código | receita de export e template do burndown da implementação ativa (ex.: `system/providers/backlog/recipes/gitlab-glab-burndown.md`) |

Análise quantitativa de 10+ issues de uma vez. Consulta pontual (ver uma issue, buscar
texto) → `backlog-query`, não esta skill.

## Bindings

- **Funil primeiro**: para qualquer análise de prioridade/score, use o documento em
  `caminhos.documento_priorizacao` (`project-config.yaml`); chave vazia → o funil de
  `org/ORG.md`; nem lá → pergunte. Fórmula, cortes, hierarquia, labels e ordem saem de lá —
  nunca de memória.
- **Escopo pelo pedido**: backlog completo (abertas) · sprint específica (milestone) ·
  fechadas do período · tudo. Ambíguo → pergunte.
- **Um export em lote** pela receita do provider → CSV em `data/` (com data no nome, nunca
  sobrescrever). Análise 100% sobre o arquivo local. Export de sprint inclui a data de
  fechamento (burndown). Prefixos de label (`TIPO::`, `PRIORIDADE::`) — confirme a
  taxonomia real pelo provider se não souber.
- **Burndown** só para escopo de sprint: HTML auto-contido em
  `data/burndown_<sprint>_YYYY-MM-DD.html` (template na receita do provider), linha ideal ×
  real por `closed_at`, real cortada no dia atual.

## Contrato de saída

`history/analyses/YYYY-MM-DD_analysis_[escopo].md`, com:

- Cabeçalho (data, fonte CSV, link do burndown se houver, nº de issues).
- **Score de saúde 0–100**: penalizações por issue — sem tipo −2 · sem prioridade −2 ·
  sem sprint −1 · zumbi (>180 dias sem atualização) −3. Classificação: 80–100 Saudável ·
  60–79 Atenção · 40–59 Problemático · 0–39 Crítico.
- Volume (abertas/fechadas), distribuição por tipo e por prioridade (barras texto + N + %).
- Saúde (tabela de problemas), top 10 issues que precisam de atenção, 3 recomendações
  acionáveis baseadas nos dados.
- Métricas de sprint quando escopo = sprint (taxa de conclusão, por assignee).

Ao entregar, mencione como abrir o CSV no Excel (Dados → De Texto/CSV, delimitador
vírgula).
