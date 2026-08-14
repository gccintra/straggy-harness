# Procedimento desta organização — priorizar backlog

Encaixe `procedimento` da ação `priorizar-backlog`. As etapas, escalas, cortes e ordenação
estão no encaixe `funil` (`references/funil.yaml`); aqui fica o julgamento que o funil não
calcula. Fonte de ambos: `docs/context_docs/sistema_priorizacao_funcionamento.md` (v2.3).

## Camada 0 — via expressa (antes do funil)

Bug com **qualquer** SIM abaixo é crítico e **fura o funil**: entra na sprint atual, com a
label de crítico do projeto. Não é ranqueado — a priorização registra o desvio.

- sistema completamente indisponível para algum perfil de usuário
- risco de perda ou vazamento de dados
- impede a conclusão de um fluxo core
- afeta um grupo grande da base (>30%)
- não existe forma de contornar

Bug menor (tem contorno, afeta <10%, funcionalidade não-core) segue o funil normal.

## Caixas de capacidade — o funil roda dentro de cada uma

O ranqueamento **nunca compara demandas de caixas diferentes**: uma melhoria não disputa
vaga com uma feature. Na lista priorizada, cada caixa é ordenada isolada.

| Caixa | Composição |
|---|---|
| 60% | novas funcionalidades (FEATURE, PRODUCT de entrega) |
| 25% | bugs menores e melhorias |
| 15% | débito técnico |

Demandas de discovery/UX (PRODUCT, REFINAMENTO) têm esteira própria do PO/designers e não
consomem a divisão — aparecem como anomalia de fila, não como item mal posicionado.

## Facilidade lida como capacidade, não como tempo

A escala de Facilidade é **geométrica**: um F=4 sozinho consome mais que três F=8 juntos.
Quando a pergunta for "o que cabe na sprint", converta pela tabela de Unidades de Dev do
documento-fonte (§7) — somar Facilidade direto dá leitura errada. A priorização ordena; o
que cabe é decisão da planning.

## Itens que o funil não sabe pontuar

Obrigação legal, aposta estratégica ou manutenção sem alcance mensurável saem da fila e são
decididos no explícito, com o motivo registrado. Nota inventada para caber no score é pior
que declarar o item incomparável.

## A análise só identifica

Anomalia vira linha no relatório com a ação sugerida. Corrigir rótulo, nota ou descrição é
passo separado, aprovado pelo usuário antes de qualquer escrita no backlog.
