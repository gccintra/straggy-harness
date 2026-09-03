---
name: backlog-prioritization
description: >
  Prioriza as demandas do backlog pelo funil declarado da organização — triagem,
  dimensões, score e faixas. Exporta os dados em lote, extrai as dimensões da demanda,
  ranqueia pela ordenação declarada, detecta anomalias (rótulo errado, score inconsistente,
  tipo errado na fila) e gera o markdown da análise no histórico.
  Acione SEMPRE que o usuário mencionar: priorização, priorizar, ranking, lista ranqueada,
  ordem de prioridade, backlog priorizado, funil, MoSCoW, ICE score, RICE, WSJF, quadrante,
  matriz esforço × valor, quais issues entram primeiro, anomalia de prioridade,
  inconsistência de label, ou qualquer pedido que combine backlog + priorizar + ordenar +
  analisar.
  IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de qualquer
  operação no backlog.
acao:
  id: priorizar-backlog
  rotulo: Priorizar backlog
  descricao: ranqueia o backlog pelo funil de priorização
objetivo: Ordenar a fila do backlog pelo funil declarado e mostrar onde os dados contradizem o funil.
entrega:
  - CSV `{caminhos.dados}issues_YYYY-MM-DD.csv`
  - relatório `{caminhos.historico}analyses/YYYY-MM-DD_priorizacao_backlog.md` com lista priorizada, anomalias por categoria e resumo de ações por severidade
portoes:
  - escopo ambíguo → pergunta antes de exportar
  - a ação só identifica anomalia — corrigir rótulo ou descrição é passo separado, aprovado pelo usuário
provider:
  dominio: backlog
  selecao: BACKLOG_PROVIDER
  capacidade: bulk-export
encaixes:
  funil:
    caminho: references/funil.yaml
    rotulo: Funil de priorização
    ajuda: As etapas do funil da sua empresa — triagem, dimensões e rubricas, fórmula do score, faixas de corte e ordem final.
    tipo: estrutura
    schema: funil-priorizacao
  procedimento:
    caminho: references/procedimento.md
    rotulo: Como fazer
    ajuda: O julgamento que o funil não calcula — exceções, bypass e desempates que dependem de contexto.
    tipo: texto-longo
---

# backlog-prioritization — workflow L2 (pack padrão)

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` (a skill **só identifica** — corrigir rótulo/descrição é passo separado, aprovado pelo usuário) |
| Métodos | `system/professions/product-specialist/methods/prioritization-selection.md` · `moscow.md` · `ice.md` |
| Provider | `system/providers/backlog/` — **sem fallback local**. Capacidade exigida: `bulk-export` |
| Código | receita de export da implementação ativa (ex.: `system/providers/backlog/recipes/gitlab-glab-analysis.md`, `linear-mcp-analysis.md`) + `recipes/analise-funil.md` (cálculo do funil, agnóstico de ferramenta) |
| Schema do funil | `system/schemas/funil-priorizacao.yaml` |


**Procedimento (encaixe).** Existindo `references/procedimento.md`, ele é o passo a passo a
seguir. A moldura acima — ação, métodos, providers, portões e contrato de saída — vale
sempre e não é substituível.

## Bindings

- **O funil declarado manda.** Antes de qualquer análise, leia a instância do encaixe
  `funil` (`references/funil.yaml`): dela saem as etapas, as escalas e rubricas, o operador
  do score, os cortes das faixas, a ordenação e o mapa de rótulos do backlog. A instância
  declara `fonte` → o documento citado é a autoridade; divergência entre os dois é anomalia
  a reportar, não decisão de execução. Nunca aplique valores decorados.
- **Escopo default**: demandas abertas ainda **fora de sprint** — é a fila que a
  priorização ordena, delimitada por `binding.fila` do funil. Pedido diferente ("só a sprint
  X") ajusta o filtro — ambíguo → pergunte. Nunca decore nome de rótulo: confirme a
  taxonomia real pelo provider (operação **listar rótulos**).
- **Um export em lote** pela receita do provider → CSV em `{caminhos.dados}issues_YYYY-MM-DD.csv`;
  toda a análise roda no arquivo local. Verifique o export (`wc -l` > 1) antes de seguir.
- **Anomalias derivam do funil** (score ≠ recalculado, rótulo ≠ faixa calculada, nota fora
  do intervalo, triagem alta em faixa de descarte, dimensão faltando na fila) e somam-se às
  declaradas em `anomalias_extras`. Detecção é aberta: aplique também o que o documento-fonte
  descrever como inconsistência.
- **Ordenação**: exatamente a etapa `ordenacao` do funil.

## Contrato de saída

`{caminhos.historico}analyses/YYYY-MM-DD_priorizacao_backlog.md`, com:

- Cabeçalho: data, nº de demandas (com/sem score), funil e versão, fonte CSV, referência ao
  documento-fonte do funil.
- **Lista Priorizada** seccionada pelas etapas de agrupamento da ordenação, na ordem
  declarada (omitir seções vazias). Tabela com identificador, score, cada dimensão em coluna
  própria, tipo, rótulo e título — score em negrito (divergente → usar o recalculado),
  anomalia inline com `⚠️` + nota sob a tabela, corrigida na sessão → `✅`.
- Seção **Anomalias** (uma subseção por categoria com ocorrência ≥1: identificador, detalhe,
  ação).
- **Resumo de Ações Prioritárias** por severidade (alta 🔴 / média 🟠 / baixa 🟡 / info ℹ️).
- Referência canônica de formato/tom: a análise mais recente em `{caminhos.historico}analyses/`.

CSV com data no nome — nunca sobrescrever o de dia anterior.
