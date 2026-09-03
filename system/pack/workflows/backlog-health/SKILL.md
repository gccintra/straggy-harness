---
name: backlog-health
description: >
  Audita a saúde do backlog detectando issues sem tipo, sem prioridade, sem sprint,
  sem assignee, possíveis duplicatas por similaridade de título e issues "zumbis"
  (abertas há mais de 6 meses sem atualização). Exporta os dados do backlog em
  uma única chamada, salva o CSV no repositório, e gera um relatório de saúde com
  recomendações e opção de correções em lote. Use quando o usuário pedir para limpar
  o backlog, encontrar inconsistências, ver duplicatas ou auditar a qualidade das issues.
  IMPORTANTE: leia .agents/system/providers/backlog/INTERFACE.md antes de qualquer
  operação no backlog.
acao:
  id: auditar-backlog
  rotulo: Auditar backlog
  descricao: saúde do backlog — inconsistências, duplicatas, zumbis
objetivo: Achar o que apodreceu no backlog — demanda sem tipo, sem prioridade, sem dono, parada há mais de 180 dias e provável duplicata.
entrega:
  - CSV `{caminhos.dados}health_audit_YYYY-MM-DD.csv`
  - relatório `{caminhos.historico}analyses/YYYY-MM-DD_health_audit.md` com resumo por problema, zumbis, grupos de duplicata e 3 recomendações
portoes:
  - correção em lote é opt-in e só existe depois do relatório entregue
  - cada lote (fechar zumbi, fechar duplicata, aplicar label) é um portão separado
  - duplicata é sugestão da ação; quem valida é o usuário
provider:
  dominio: backlog
  selecao: BACKLOG_PROVIDER
  capacidade: bulk-export
encaixes:
  procedimento:
    caminho: references/procedimento.md
    rotulo: Como fazer
    ajuda: O que sua empresa considera uma demanda malformada, e o que fazer com as que aparecerem.
    tipo: texto-longo
---

# backlog-health — workflow L2 (pack padrão)

| Camada | Referência |
|---|---|
| Restrições | `system/CONSTITUTION.md` (nunca fechar/editar/mesclar issue sem aprovação explícita; cada lote é um portão) |
| Provider | `system/providers/backlog/` — **sem fallback local**. Capacidade exigida: `bulk-export` |

Varre o backlog inteiro de uma vez. Correção pontual de uma issue → `backlog-query`.


**Procedimento (encaixe).** Existindo `references/procedimento.md`, ele é o passo a passo a
seguir. A moldura acima — ação, métodos, providers, portões e contrato de saída — vale
sempre e não é substituível.

## Bindings

- **Um export em lote** (só demandas abertas) com timestamps, responsáveis, URL e
  descrição resumida (100 chars) → `{caminhos.dados}health_audit_YYYY-MM-DD.csv`. Verifique `wc -l`.
- Prefixos de tipo/prioridade: confirme a taxonomia real de labels pelo provider.

## Detecções (uma issue pode cair em vários grupos)

| Grupo | Critério |
|---|---|
| Sem tipo / sem prioridade | nenhuma label com o prefixo correspondente |
| Sem sprint / sem assignee | milestone/assignee vazio |
| Zumbi | `updated_at` há mais de **180 dias** |
| Possível duplicata | títulos com 3+ palavras significativas em comum (excluindo artigos e verbos genéricos) — **sugestão**, o usuário valida |

## Contrato de saída

`{caminhos.historico}analyses/YYYY-MM-DD_health_audit.md`: resumo executivo (tabela problema × N × %),
zumbis (IID, título, dias, URL), grupos de duplicatas com sugestão de qual manter,
amostras (top 15 mais antigas) de sem-tipo e sem-prioridade, e 3 recomendações
(imediato / esta semana / grooming).

## Correções em lote (opt-in, após o relatório)

Ofereça: [A] fechar zumbis · [B] fechar duplicatas validadas pelo usuário · [C] aplicar
label de tipo (usuário informa qual) · [D] nada. **Aguarde a escolha.** Execução:
comandos do provider, sequencial, progresso a cada 10 issues, registro das ações no
relatório (seção "Ações executadas"). Zumbi pode ter razão de existir — o usuário decide.
