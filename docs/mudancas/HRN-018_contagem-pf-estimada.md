# HRN-018 — Contagem de pontos de função antes do desenvolvimento

| | |
|---|---|
| **Estado** | verde |
| **Camada** | L2 org |
| **Arquivos** | `org/workflows/contagem-pf-estimada/**` · `org/workflows/backlog-prioritization/evals/prioriza-esforco-valor/caso.yaml` |
| **Data** | 2026-09-24 |

## História

Como **PM da Websis**, quero **gerar a contagem de pontos de função de uma demanda no mesmo
padrão do contador**, para **a empresa validar se tem caixa antes de mandar para desenvolvimento**.

Hoje toda demanda espera o contador montar a planilha. A contagem estimada é regrada (IFPUG +
NESMA + deflatores SISP) e pode ser feita pelo agente, com revisão humana.

## Regras de negócio

- **RN-01.** A contagem segue o IFPUG; tipo de contagem, fronteira, tipo de função,
  complexidade e deflator são decididos por demanda, nunca fixados.
- **RN-02.** A planilha sai do template do contador (5 abas, fórmulas intactas); totais são os
  das fórmulas.
- **RN-03.** Tabela de funções e totais são mostrados e aprovados antes de gerar o `.xlsx`.
- **RN-04.** Ambiguidade que muda o total vira pergunta, não suposição.
- **RN-05.** Responsável na planilha: Gustavo da Costa Cintra.

## Impacto

| Raio | Achados | O que fazer |
|---|---|---|
| Cita o alvo | nenhum (`pontos de função`, `NESMA`, `APF` sem ocorrência) | — |
| Esteira | fora da esteira (sem `produz`/`requer`) | — |
| Evals | ação nova; `priorizar-backlog` ganha caso negativo em `org/` | criar |
| Organização | nada escrito antes; override de eval em `backlog-prioritization` é aditivo | — |
| Camada | template SENAT, deflatores SISP, responsável: não passam no teste do pack | L2 org |

## Critérios de aceite

| # | Critério | Prova |
|---|---|---|
| CA-01 | workflow válido, ação coberta por `atende` e `confunde_com` | `build.sh --strict` |
| CA-02 | "faz a contagem estimada de PF da #1022" aciona a contagem, não a priorização | eval `contagem-pf-estimada/estima-pf` |
| CA-03 | "prioriza por esforço e valor" não aciona a contagem | eval `backlog-prioritization/prioriza-esforco-valor` |
| CA-04 | script reproduz os totais do contador (HU06.06: 18 / 11,5) | `preencher_planilha.py` com as funções da planilha original |

## Fora de escopo

- Enviar a planilha a alguém ou anexá-la na issue.
- Revisão da contagem pelo contador (processo humano).
- Commit — `@committer`.

## Registro

- `build.sh --strict`: 0 erro, 0 aviso. `--fix` regenerou só `docs/WORKFLOWS.md`; `system/ACOES.md` intocado.
- Evals `estima-pf` e `prioriza-esforco-valor`: passaram (claude-headless).
- CA-04: script com as funções da planilha HU06.06 → 18 PF IFPUG / 11,5 PF FS, igual ao contador.
- Não previsto: teste `--org <vazio>` reprova por divergência de `WORKFLOWS.md` (lista workflows
  da org). Pré-existente — reprova igual sem esta mudança. Fora do escopo.
- Não previsto: sem LibreOffice no ambiente; planilha sai sem valores em cache e o Excel
  recalcula ao abrir (`fullCalcOnLoad`). O resumo na conversa vem do cálculo do script.
