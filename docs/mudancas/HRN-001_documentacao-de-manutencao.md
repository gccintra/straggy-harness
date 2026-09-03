# HRN-001 — Documentação do harness que roda hoje

| | |
|---|---|
| **Estado** | verde |
| **Camada** | L2 pack (frontmatter dos workflows) + adapter (`runtime/`) + docs |
| **Arquivos** | 27 × `SKILL.md` · `runtime/adapters/harness.py` · `runtime/build.sh` · `docs/` |
| **Data** | 2026-09-01 |

## História

Como **quem mantém o harness**, quero **saber o que ele já faz, onde cada coisa mora e o que
cada ação entrega**, para **editar sem reconstruir o inventário de memória a cada vez**.

`docs/` tinha 14 arquivos e 12 deles descreviam o Hub — o produto com interface, do qual nada
está implementado. Do harness que roda restavam `ARCHITECTURE.md` (regra normativa de
camadas) e `MODOS.md`. Nenhum respondia "quais são os workflows, o que cada um entrega, onde
ele para e em que arquivo eu mexo". Essa resposta existia só espalhada em prosa dentro dos
`SKILL.md`, com nome de seção diferente em cada um: **7 de 22 declaravam contrato de saída e
2 declaravam portão.**

## Regras de negócio

- **RN-01.** Inventário não se escreve à mão. O que existe no frontmatter é a fonte; a
  documentação é derivada, e o build reprova quando as duas divergem.
- **RN-02.** Especificação de futuro e descrição do presente não convivem na mesma pasta.
- **RN-03.** Toda ação de trabalho declara o que entrega e onde para. Ação sem portão
  declarado é ação sem controle humano visível (`CONSTITUTION.md` §2 e §5).
- **RN-04.** Persona não declara entrega nem portão — é identidade, não procedimento.
- **RN-05.** Nenhum portão existente foi afrouxado; a mudança só torna explícito o que já
  valia.

## Critérios de aceite

| # | Critério | Prova |
|---|---|---|
| CA-01 | Todo workflow declara `objetivo` | `build.sh --strict` reprova quem não declara |
| CA-02 | Toda ação de trabalho declara `entrega` e `portoes` | `build.sh --strict` reprova quem não declara |
| CA-03 | Persona que declarar `entrega`/`portoes` gera aviso | `build.sh --strict` |
| CA-04 | `docs/WORKFLOWS.md` é gerado e reprova divergência sem `--fix` | `build.sh --strict` após mexer num frontmatter |
| CA-05 | O manifesto carrega os três campos novos, sem quebrar o schema | `runtime/manifest.json`, schema 1 (campo aditivo) |
| CA-06 | `docs/` raiz só contém o que roda hoje | inspeção — os 12 do Hub estão em `docs/hub/` |

## Fora de escopo

- **Reescrever os `SKILL.md`.** A declaração entrou no frontmatter; a prosa do corpo
  continua como estava. Consolidar as seções `Contrato de saída` espalhadas é HRN próprio.
- **Eval para as declarações novas.** São estrutura, não comportamento — o build cobre.
- **Documentar `docs/hub/`.** Aquilo é espec de futuro e não muda de estado com esta HRN.

## Registro

Três campos novos no frontmatter (`objetivo`, `entrega`, `portoes`), preenchidos nos 27
workflows a partir do que cada `SKILL.md` já dizia — nada foi inventado. `harness.py` ganhou
validação, os campos no manifesto e o gerador `ficha_workflows()`, que usa o mesmo mecanismo
de bloco marcado do `system/ACOES.md`.

O que a execução mostrou e a proposta não previa: `figma-node-reader` tem `PERSONA.md`
porque é assim que o runtime descobre subagente, e por isso aparecia na tabela de personas.
O gerador passou a filtrar `origem == sistema` — máquina do harness não é com quem o usuário
conversa.
