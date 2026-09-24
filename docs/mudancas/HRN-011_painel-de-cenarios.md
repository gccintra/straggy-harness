# HRN-011 — Painel de cenários: trocar estado e perfil do protótipo sem mexer na URL

| | |
|---|---|
| **Estado** | verde |
| **Camada** | L2 pack |
| **Arquivos** | `system/pack/workflows/design-setup/SKILL.md` · `system/pack/workflows/design-setup/references/stack-react-vite.md` · `system/pack/workflows/design-screen/SKILL.md` · `system/workflows/html-to-figma/SKILL.md` · `docs/WORKFLOWS.md` (gerado) |
| **Data** | 2026-09-23 |

## História

Como **quem apresenta o protótipo ao cliente**, quero **um painel flutuante que troca o
estado da tela atual (e o perfil de quem a vê) com um clique**, para **mostrar todos os
cenários sem pedir ao cliente que edite a query da URL**.

Hoje cada estado vive em parâmetros de query (`?state=`, `?forma=`, `?passo=`…). Funciona
para prints e export, mas na apresentação ninguém descobre nem digita esses parâmetros.

## Regras de negócio

- **RN-01.** A URL continua sendo a fonte da verdade. O painel só grava parâmetros de query
  (ou navega para outro caminho); prints, export e link direto não mudam.
- **RN-02.** Cada rota declara seus cenários: grupos de opções com rótulo legível, cada opção
  definindo parâmetros de query ou um caminho de destino.
- **RN-03.** O painel é dinâmico: mostra só o que a rota atual declarou; rota sem declaração
  mostra "sem cenários".
- **RN-04.** Dimensão global (ex.: perfil) é declarada uma vez no protótipo, gravada em query
  (`?perfil=`) e preservada pelo painel ao navegar. Projeto sem dimensão global não mostra a
  seção.
- **RN-05.** Atalho: tecla `P`, sem modificador, ignorada com foco em campo editável
  (input, textarea, select, contenteditable).
- **RN-06.** O atalho está escrito em três lugares: cabeçalho do painel e dica do botão
  flutuante · entrega de cada tela (`design-screen`) · `prototype/README.md` (seção
  "Apresentando ao cliente").
- **RN-07.** O painel nunca aparece em captura: oculto com `?export=1` e sob automação
  (`navigator.webdriver`), mesmo que tenha ficado aberto na sessão.

## Impacto

| Raio | Achados | O que fazer |
|---|---|---|
| Cita o alvo | `?state=` em `design-screen/SKILL.md:13,64`, `design-setup/references/stack-react-vite.md:39`, `html-to-figma/SKILL.md:59,111`. `prototype-prints` navega por URL, sem citar `?state=` | atualizar design-screen e stack; html-to-figma ganha uma linha (painel oculto em `?export=1`); prototype-prints coberto pela RN-07 |
| Esteira | `prototipo-validado` inalterado | — (vazio) |
| Evals | `cria-tela`, `configura-design-system`, `analisa-demanda-de-tela` — nenhuma ação muda | — (vazio) |
| Organização | nenhum override de `design-screen` ou `design-setup` em `org/` | — (vazio) |
| Camada | pack: qualquer empresa com protótipo usaria sem editar; nenhum portão tocado | mantém |

## Critérios de aceite

| # | Critério | Prova |
|---|---|---|
| CA-01 | Contrato e ficha íntegros após a mudança de `entrega` | `./build.sh --strict` sai 0 |
| CA-02 | Organização recém-criada não fica sem padrão | `--org <vazio> --out <temporário>` sem aviso |
| CA-03 | `--fix` altera só `docs/WORKFLOWS.md`, nunca `system/ACOES.md` | `--fix` + `git status` |

## Fora de escopo

- Adequar o `prototype/` atual deste projeto ao painel — código do projeto, passo à parte
  pela `design-screen`.
- Lógica de permissão por perfil: o painel só troca o valor; cada tela decide o que muda.

## Registro

- CA-01: `build.sh --strict` → `contrato: ok (0 aviso(s))`, exit 0 (após `--fix`).
- CA-02: `--org <vazio>` sem aviso de "sem padrão". Reporta 1 erro de `WORKFLOWS.md`
  divergente — **pré-existente** (reproduzido com a mudança em stash): a ficha versionada
  inclui os workflows de `org/`, que somem com org vazia. Não é desta HRN.
- CA-03: `--fix` alterou só `docs/WORKFLOWS.md` (2 linhas de `entrega`); `system/ACOES.md`
  intacto.
- Não previsto: o `prototype/` deste projeto ainda não tem o painel — próximo passo via
  `design-screen`.
