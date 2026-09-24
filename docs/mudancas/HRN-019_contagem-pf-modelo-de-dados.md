# HRN-019 — Contagem de PF lê o modelo de dados, não a tela

| | |
|---|---|
| **Estado** | verde |
| **Camada** | L2 org |
| **Arquivos** | `org/workflows/contagem-pf-estimada/references/regras-contagem.md` |
| **Data** | 2026-09-24 |

## História

Como **analista que estima PF antes do desenvolvimento**, quero **que a contagem parta do
modelo lógico que o requisito descreve**, para **chegar à mesma classificação que o
contador independente**.

Hoje a skill tem as regras IFPUG, mas não diz como enxergar a demanda. Ela tende a
classificar pelo que a tela mostra, e aí um dado com ciclo de vida próprio vira atributo de
um grupo existente. A contagem diverge da auditoria.

## Regras de negócio

- **RN-01.** A seção nova é critério de leitura. Não traz exemplo, caso concreto nem
  regra casuística.
- **RN-02.** Portões, contrato e exemplos de calibração ficam inalterados.

## Impacto

| Raio | Achados | O que fazer |
|---|---|---|
| Cita o alvo | `org/workflows/contagem-pf-estimada/SKILL.md` (tabela de camadas) | nada; o caminho não muda |
| Esteira | vazio (a ação não declara `produz`/`requer`) | — |
| Evals | `evals/estima-pf` só cobre gatilho | nada |
| Organização | o alvo é conteúdo da própria organização | — |
| Camada | L2 org, workflow próprio | mantém |

## Critérios de aceite

| # | Critério | Prova |
|---|---|---|
| CA-01 | build sem aviso | `./.agents/build.sh --strict` |
| CA-02 | runtime gerado igual à fonte | `./.agents/build.sh --check` |

## Fora de escopo

- Reescrever as regras IFPUG existentes ou os exemplos do contador.
- Regras específicas de histórico, listagem ou tipo de transação.

## Registro

Uma seção "Como olhar a demanda" foi inserida antes de `## Funções`. Não houve outra
mudança.
